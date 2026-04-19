from __future__ import annotations

from pathlib import Path
import sys


PROJECT_ROOT = Path(__file__).resolve().parents[1]
SRC_PATH = PROJECT_ROOT / "src"
for path in (PROJECT_ROOT, SRC_PATH):
    if str(path) not in sys.path:
        sys.path.insert(0, str(path))

from cotizador_ia.settings import bootstrap_env, get_connection_string
from connectors.syspro_sqlserver import probe_connection, query


def main() -> int:
    bootstrap_env()
    connection_string = get_connection_string()
    print("CONNECTION_OK: configured")
    print("CONNECTION_STRING_PREFIX:", connection_string[:80] + "...")

    probe = probe_connection()
    print("PROBE:", probe)

    samples = {
        "InvMaster": "SELECT TOP (5) StockCode, Description, StockUom, ProductClass, Ebq, WarehouseToUse FROM dbo.InvMaster ORDER BY StockCode;",
        "BomStructure": "SELECT TOP (5) ParentPart, Component, Route, SequenceNum, QtyPer, ScrapPercentage, FixedQtyPerFlag, FixedQtyPer FROM dbo.BomStructure ORDER BY ParentPart, SequenceNum;",
        "BomOperations": "SELECT TOP (5) StockCode, Route, Operation, WorkCentre, ISetUpTime, IRunTime, IStartupTime, ITeardownTime FROM dbo.BomOperations ORDER BY StockCode, Route, Operation;",
        "BomWorkCentre": "SELECT TOP (5) WorkCentre, Description, CostCentre, SetUpRate1, RunTimeRate1, FixOverRate1, VarOverRate1 FROM dbo.BomWorkCentre ORDER BY WorkCentre;",
        "WipMaster": "SELECT TOP (5) Job, JobDescription, StockCode, Warehouse, QtyToMake, QtyManufactured, ExpLabour, ExpMaterial FROM dbo.WipMaster ORDER BY Job;",
    }

    for name, sql in samples.items():
        rows = query(sql)
        print(f"{name}: {len(rows)} rows")
        for row in rows[:2]:
            print(row)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
