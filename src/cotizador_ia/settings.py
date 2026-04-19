from __future__ import annotations

import os
from pathlib import Path
from typing import Dict, Iterable, Optional


PROJECT_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_ENV_PATHS = (
    PROJECT_ROOT / ".env",
    PROJECT_ROOT / "configurations" / ".env",
)


def _parse_env_line(line: str) -> tuple[str, str] | None:
    stripped = line.strip()
    if not stripped or stripped.startswith("#") or "=" not in stripped:
        return None
    key, value = stripped.split("=", 1)
    value = value.strip()
    if value.startswith(("'", '"')) and value.endswith(("'", '"')) and len(value) >= 2:
        value = value[1:-1]
    return key.strip(), value


def load_env_file(path: Path) -> Dict[str, str]:
    loaded: Dict[str, str] = {}
    if not path.exists():
        return loaded
    for raw_line in path.read_text(encoding="utf-8").splitlines():
        parsed = _parse_env_line(raw_line)
        if parsed is None:
            continue
        key, value = parsed
        loaded[key] = value
        os.environ.setdefault(key, value)
    return loaded


def bootstrap_env(paths: Optional[Iterable[Path]] = None) -> Dict[str, str]:
    merged: Dict[str, str] = {}
    for path in paths or DEFAULT_ENV_PATHS:
        merged.update(load_env_file(path))
    return merged


def get_connection_string() -> str:
    bootstrap_env()
    connection_string = os.getenv("SQLSERVER_CONNECTION_STRING", "").strip()
    if connection_string:
        return connection_string

    host = os.getenv("SYSPRO_DB_HOST", "192.168.1.5").strip()
    port = os.getenv("SYSPRO_DB_PORT", "1433").strip()
    database = os.getenv("SYSPRO_DB_NAME", "EncorePlasti1").strip()
    user = os.getenv("SYSPRO_DB_USER", "").strip()
    password = os.getenv("SYSPRO_DB_PASSWORD", "").strip()
    encrypt = os.getenv("SYSPRO_DB_ENCRYPT", "false").strip().lower() == "true"
    trust_server_certificate = (
        os.getenv("SYSPRO_DB_TRUST_SERVER_CERTIFICATE", "false").strip().lower() == "true"
    )
    timeout_seconds = os.getenv("SYSPRO_DB_TIMEOUT_SECONDS", "15").strip()

    if not user:
        raise RuntimeError(
            "No se encontro SQLSERVER_CONNECTION_STRING ni las variables SYSPRO_DB_* necesarias."
        )

    return (
        f"Data Source={host},{port};"
        f"Initial Catalog={database};"
        f"User ID={user};"
        f"Password={password};"
        f"Encrypt={'True' if encrypt else 'False'};"
        f"TrustServerCertificate={'True' if trust_server_certificate else 'False'};"
        f"Connection Timeout={timeout_seconds};"
    )

