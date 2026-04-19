from __future__ import annotations

import argparse
from datetime import datetime
from pathlib import Path
import sys


PROJECT_ROOT = Path(__file__).resolve().parents[1]
SRC_PATH = PROJECT_ROOT / "src"
for path in (PROJECT_ROOT, SRC_PATH):
    if str(path) not in sys.path:
        sys.path.insert(0, str(path))

from cotizador_ia.bom_costing import format_report


def main() -> int:
    parser = argparse.ArgumentParser(description="Generate a SYSPRO-style BOM costing report.")
    parser.add_argument("stock_code", nargs="?", default="9320000432")
    parser.add_argument("--report-type", default="What-if Costing Report")
    parser.add_argument("--batch-qty", type=float, default=None, help="Override the economic batch quantity for the selected parent.")
    parser.add_argument("--tree", action="store_true", help="Generate a hierarchical report by parent/children levels.")
    parser.add_argument(
        "--output",
        default="outputs/9320000432_what_if_report.txt",
        help="Relative path where the report will be written.",
    )
    args = parser.parse_args()

    report = format_report(args.stock_code, report_type=args.report_type, route="0", batch_qty=args.batch_qty) if not args.tree else None
    if args.tree:
        from cotizador_ia.bom_costing import format_tree_report

        report = format_tree_report(args.stock_code, report_type=args.report_type, route="0", batch_qty=args.batch_qty)
    output_path = PROJECT_ROOT / args.output
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(report, encoding="utf-8")
    print(report)
    print()
    print(f"Saved to: {output_path}")
    print(f"Generated at: {datetime.now().isoformat(timespec='seconds')}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
