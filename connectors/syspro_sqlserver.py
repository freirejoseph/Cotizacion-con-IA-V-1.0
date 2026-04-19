from __future__ import annotations

import json
import os
import platform
import subprocess
from typing import Any, Iterable, List, Sequence

from cotizador_ia.settings import get_connection_string


def _rows_to_dicts(columns: Sequence[str], rows: Iterable[Sequence[Any]]) -> List[dict[str, Any]]:
    return [dict(zip(columns, row)) for row in rows]


def _clean_sqlclient_connection_string(connection_string: str) -> str:
    parts = []
    for segment in connection_string.split(";"):
        cleaned = segment.strip()
        if not cleaned:
            continue
        key = cleaned.split("=", 1)[0].strip().lower()
        if key == "command timeout":
            continue
        parts.append(cleaned)
    return ";".join(parts)


def _query_with_pyodbc(query: str, params: Sequence[Any] | None = None) -> List[dict[str, Any]]:
    import pyodbc  # type: ignore

    conn = pyodbc.connect(get_connection_string(), autocommit=False)
    try:
        cursor = conn.cursor()
        cursor.execute(query, params or ())
        columns = [column[0] for column in cursor.description] if cursor.description else []
        rows = cursor.fetchall() if columns else []
        return _rows_to_dicts(columns, rows)
    finally:
        conn.close()


def _query_with_powershell(query: str) -> List[dict[str, Any]]:
    connection_string = _clean_sqlclient_connection_string(get_connection_string())
    ps_script = r'''
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Data
$conn = New-Object System.Data.SqlClient.SqlConnection $env:SQL_CONN
$cmd = $conn.CreateCommand()
$cmd.CommandText = $env:SQL_QUERY
$da = New-Object System.Data.SqlClient.SqlDataAdapter $cmd
$dt = New-Object System.Data.DataTable
$conn.Open()
[void]$da.Fill($dt)
$conn.Close()
$rows = @()
foreach ($row in $dt.Rows) {
  $obj = [ordered]@{}
  foreach ($col in $dt.Columns) { $obj[$col.ColumnName] = $row[$col.ColumnName] }
  $rows += [pscustomobject]$obj
}
$rows | ConvertTo-Json -Depth 8 -Compress
'''
    env = os.environ.copy()
    env["SQL_CONN"] = connection_string
    env["SQL_QUERY"] = query
    completed = subprocess.run(
        ["powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", ps_script],
        env=env,
        capture_output=True,
        text=True,
        check=False,
    )
    if completed.returncode != 0:
        raise RuntimeError((completed.stderr or completed.stdout).strip())
    output = completed.stdout.strip()
    if not output:
        return []
    data = json.loads(output)
    if isinstance(data, dict):
        return [data]
    return data


def query(query: str, params: Sequence[Any] | None = None) -> List[dict[str, Any]]:
    if platform.system().lower() == "windows":
        return _query_with_powershell(query)
    try:
        import pyodbc  # type: ignore  # noqa: F401
    except ImportError as exc:
        raise RuntimeError(
            "pyodbc no esta disponible y el fallback por PowerShell solo funciona en Windows."
        ) from exc
    return _query_with_pyodbc(query, params=params)


def probe_connection() -> List[dict[str, Any]]:
    return query("SELECT TOP (1) name AS table_name FROM sys.tables ORDER BY name;")


def fetch_table_sample(table_name: str, columns: Sequence[str], top_n: int = 5) -> List[dict[str, Any]]:
    column_list = ", ".join(columns)
    sql = f"SELECT TOP ({int(top_n)}) {column_list} FROM dbo.{table_name} ORDER BY 1;"
    return query(sql)
