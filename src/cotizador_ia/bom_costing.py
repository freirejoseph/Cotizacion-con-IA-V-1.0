from __future__ import annotations

from dataclasses import dataclass, field
from functools import lru_cache
from decimal import Decimal, ROUND_HALF_UP
from typing import Dict, List, Sequence, Tuple

from connectors.syspro_sqlserver import query


Q5 = Decimal("0.00001")
Q6 = Decimal("0.000001")


def _r5(value: float | int | str | Decimal) -> float:
    return float(Decimal(str(value)).quantize(Q5, rounding=ROUND_HALF_UP))


@dataclass
class CostBreakdown:
    material: float = 0.0
    labor: float = 0.0
    fixed: float = 0.0
    variable: float = 0.0

    @property
    def total(self) -> float:
        return self.material + self.labor + self.fixed + self.variable

    def scale(self, qty: float) -> "CostBreakdown":
        return CostBreakdown(
            material=_r5(self.material * qty),
            labor=_r5(self.labor * qty),
            fixed=_r5(self.fixed * qty),
            variable=_r5(self.variable * qty),
        )

    def add(self, other: "CostBreakdown") -> "CostBreakdown":
        return CostBreakdown(
            material=_r5(self.material + other.material),
            labor=_r5(self.labor + other.labor),
            fixed=_r5(self.fixed + other.fixed),
            variable=_r5(self.variable + other.variable),
        )


@dataclass
class ComponentLine:
    stock_code: str
    description: str
    warehouse: str
    qty_per: float
    scrap_pct: float
    qty_required: float
    breakdown: CostBreakdown

    @property
    def qty_neta(self) -> float:
        return float(Decimal(str(self.qty_required)).quantize(Q6, rounding=ROUND_HALF_UP))

    @property
    def total(self) -> float:
        return self.breakdown.total


@dataclass
class OperationLine:
    operation: str
    work_centre: str
    rate_ind: int
    labor: float
    fixed: float
    variable: float
    subcontract: float = 0.0
    setup_time: float = 0.0
    run_time: float = 0.0
    startup_time: float = 0.0
    teardown_time: float = 0.0
    unit_capacity: float = 0.0

    @property
    def total(self) -> float:
        return self.labor + self.fixed + self.variable + self.subcontract


@dataclass
class TreeComponentLine:
    stock_code: str
    description: str
    warehouse: str
    qty_per: float
    scrap_pct: float
    qty_required: float
    breakdown: CostBreakdown
    node: "TreeNode" | None = None

    @property
    def qty_neta(self) -> float:
        return float(Decimal(str(self.qty_required)).quantize(Q6, rounding=ROUND_HALF_UP))

    @property
    def total(self) -> float:
        return self.breakdown.total


@dataclass
class TreeNode:
    stock_code: str
    description: str
    warehouse: str
    route: str
    ebq: float
    bom_breakdown: CostBreakdown
    op_breakdown: CostBreakdown
    components: List[TreeComponentLine] = field(default_factory=list)
    operations: List[OperationLine] = field(default_factory=list)

    @property
    def total_breakdown(self) -> CostBreakdown:
        return self.bom_breakdown.add(self.op_breakdown)


def _norm(code: str) -> str:
    return code.strip()


@lru_cache(None)
def get_master(stock_code: str) -> Dict:
    rows = query(
        f"""
        SELECT LTRIM(RTRIM(StockCode)) AS StockCode,
               Description,
               MaterialCost,
               LabourCost,
               FixOverhead,
               VariableOverhead,
               Ebq,
               WarehouseToUse,
               StockUom,
               ProductClass
        FROM dbo.InvMaster
        WHERE LTRIM(RTRIM(StockCode)) = '{_norm(stock_code)}';
        """
    )
    return rows[0] if rows else {}


@lru_cache(None)
def get_warehouse_cost(stock_code: str) -> Dict:
    master = get_master(stock_code)
    wh = str(master.get("WarehouseToUse", "") or "").strip()
    if not wh:
        return {}
    rows = query(
        f"""
        SELECT TOP (1)
               LTRIM(RTRIM(StockCode)) AS StockCode,
               LTRIM(RTRIM(Warehouse)) AS Warehouse,
               UnitCost,
               LastCostEntered,
               CostMultiplier
        FROM dbo.InvWarehouse
        WHERE LTRIM(RTRIM(StockCode)) = '{_norm(stock_code)}'
          AND LTRIM(RTRIM(Warehouse)) = '{wh}';
        """
    )
    return rows[0] if rows else {}


@lru_cache(None)
def get_whatif_cost(stock_code: str, warehouse: str | None = None) -> Dict:
    warehouse = str(warehouse or "").strip()
    if warehouse:
        rows = query(
            f"""
            SELECT TOP (1)
                   LTRIM(RTRIM(StockCode)) AS StockCode,
                   LTRIM(RTRIM(Warehouse)) AS Warehouse,
                   WhatIfMatCost,
                   WhatIfLabCost,
                   WhatIfFixCost,
                   WhatIfVarCost,
                   WhatIfSubContCost
            FROM dbo.InvWhatIfCost
            WHERE LTRIM(RTRIM(StockCode)) = '{_norm(stock_code)}'
              AND LTRIM(RTRIM(Warehouse)) = '{warehouse}';
            """
        )
        if rows:
            return rows[0]
    rows = query(
        f"""
        SELECT TOP (1)
               LTRIM(RTRIM(StockCode)) AS StockCode,
               LTRIM(RTRIM(Warehouse)) AS Warehouse,
               WhatIfMatCost,
               WhatIfLabCost,
               WhatIfFixCost,
               WhatIfVarCost,
               WhatIfSubContCost
        FROM dbo.InvWhatIfCost
        WHERE LTRIM(RTRIM(StockCode)) = '{_norm(stock_code)}'
        ORDER BY CASE WHEN LTRIM(RTRIM(Warehouse)) = '{warehouse}' THEN 0 ELSE 1 END,
                 Warehouse;
        """
    )
    return rows[0] if rows else {}


@lru_cache(None)
def get_bom(stock_code: str, route: str = "0") -> Tuple[Dict, ...]:
    rows = query(
        f"""
        SELECT LTRIM(RTRIM(Component)) AS Component,
               QtyPer,
               QtyPerEnt,
               ScrapPercentage,
               ScrapQuantity,
               ScrapQuantityEnt,
               FixedQtyPerFlag,
               FixedQtyPer,
               FixedQtyPerEnt,
               Warehouse,
               UomFlag,
               SequenceNum,
               RollUpCost
        FROM dbo.BomStructure
        WHERE LTRIM(RTRIM(ParentPart)) = '{_norm(stock_code)}'
          AND LTRIM(RTRIM(Route)) = '{_norm(route)}'
        ORDER BY SequenceNum, Component;
        """
    )
    return tuple(rows)


@lru_cache(None)
def get_operations(stock_code: str, route: str = "0") -> Tuple[Dict, ...]:
    rows = query(
        f"""
        SELECT LTRIM(RTRIM(Route)) AS Route,
               Operation,
               LTRIM(RTRIM(WorkCentre)) AS WorkCentre,
               WcRateInd,
               SubcontractFlag,
               ISetUpTime,
               IRunTime,
               IStartupTime,
               ITeardownTime,
               IWaitTime,
               IStartupQty,
               IUnitCapacity,
               SubOpUnitValue,
               SubWhatIfValue
        FROM dbo.BomOperations
        WHERE LTRIM(RTRIM(StockCode)) = '{_norm(stock_code)}'
          AND LTRIM(RTRIM(Route)) = '{_norm(route)}'
        ORDER BY Route, Operation;
        """
    )
    return tuple(rows)


@lru_cache(None)
def get_work_centre(work_centre: str) -> Dict:
    rows = query(
        f"""
        SELECT LTRIM(RTRIM(WorkCentre)) AS WorkCentre,
               Description,
               CostCentre,
               SetUpRate1, RunTimeRate1, FixOverRate1, VarOverRate1,
               StartupRate1, TeardownRate1,
               SetUpRate2, RunTimeRate2, FixOverRate2, VarOverRate2,
               StartupRate2, TeardownRate2,
               SetUpRate3, RunTimeRate3, FixOverRate3, VarOverRate3,
               StartupRate3, TeardownRate3,
               SetUpRate4, RunTimeRate4, FixOverRate4, VarOverRate4,
               StartupRate4, TeardownRate4,
               SetUpRate5, RunTimeRate5, FixOverRate5, VarOverRate5,
               StartupRate5, TeardownRate5,
               SetUpRate6, RunTimeRate6, FixOverRate6, VarOverRate6,
               StartupRate6, TeardownRate6,
               SetUpRate7, RunTimeRate7, FixOverRate7, VarOverRate7,
               StartupRate7, TeardownRate7,
               SetUpRate8, RunTimeRate8, FixOverRate8, VarOverRate8,
               StartupRate8, TeardownRate8,
               SetUpRate9, RunTimeRate9, FixOverRate9, VarOverRate9,
               StartupRate9, TeardownRate9
        FROM dbo.BomWorkCentre
        WHERE LTRIM(RTRIM(WorkCentre)) = '{_norm(work_centre)}';
        """
    )
    return rows[0] if rows else {}


def _get_rate(row: Dict, prefix: str, index: int) -> float:
    key = f"{prefix}{index}"
    value = row.get(key, 0.0)
    return _r5(value or 0.0)


def _leaf_breakdown(stock_code: str) -> CostBreakdown:
    master = get_master(stock_code)
    if not master:
        return CostBreakdown()
    warehouse = str(master.get("WarehouseToUse", "") or "").strip()
    whatif = get_whatif_cost(stock_code, warehouse)
    if whatif:
        return CostBreakdown(
            material=_r5(whatif.get("WhatIfMatCost") or 0.0),
            labor=_r5(whatif.get("WhatIfLabCost") or 0.0),
            fixed=_r5(whatif.get("WhatIfFixCost") or 0.0),
            variable=_r5(whatif.get("WhatIfVarCost") or 0.0),
        )
    material = _r5(master.get("MaterialCost") or 0.0)
    labor = _r5(master.get("LabourCost") or 0.0)
    fixed = _r5(master.get("FixOverhead") or 0.0)
    variable = _r5(master.get("VariableOverhead") or 0.0)
    if material == 0.0:
        warehouse_cost = get_warehouse_cost(stock_code)
        material = _r5(warehouse_cost.get("UnitCost") or warehouse_cost.get("LastCostEntered") or 0.0)
    return CostBreakdown(material=material + labor + fixed + variable)


def _component_breakdown(stock_code: str, warehouse: str | None = None) -> CostBreakdown:
    whatif = get_whatif_cost(stock_code, warehouse)
    if whatif:
        return CostBreakdown(
            material=_r5(whatif.get("WhatIfMatCost") or 0.0),
            labor=_r5(whatif.get("WhatIfLabCost") or 0.0),
            fixed=_r5(whatif.get("WhatIfFixCost") or 0.0),
            variable=_r5(whatif.get("WhatIfVarCost") or 0.0),
        )
    return _leaf_breakdown(stock_code)


def _effective_batch_qty(master: Dict, batch_qty: float | int | str | None) -> float:
    if batch_qty is not None:
        value = _r5(batch_qty)
        if value > 0:
            return value
    value = _r5(master.get("Ebq") or 1.0) if master else 1.0
    return value if value > 0 else 1.0


def _operation_breakdown(
    stock_code: str,
    route: str = "0",
    batch_qty: float | int | str | None = None,
) -> Tuple[CostBreakdown, Tuple[OperationLine, ...]]:
    master = get_master(stock_code)
    ebq = _effective_batch_qty(master, batch_qty)

    breakdown = CostBreakdown()
    lines: List[OperationLine] = []

    for op in get_operations(stock_code, route):
        subcontract_flag = str(op.get("SubcontractFlag") or "").strip().upper()
        rate_ind = int(op.get("WcRateInd") or 1)
        work_centre = get_work_centre(str(op.get("WorkCentre") or ""))
        if not work_centre:
            continue

        setup_rate = _get_rate(work_centre, "SetUpRate", rate_ind)
        run_rate = _get_rate(work_centre, "RunTimeRate", rate_ind)
        fixed_rate = _get_rate(work_centre, "FixOverRate", rate_ind)
        variable_rate = _get_rate(work_centre, "VarOverRate", rate_ind)
        startup_rate = _get_rate(work_centre, "StartupRate", rate_ind)
        teardown_rate = _get_rate(work_centre, "TeardownRate", rate_ind)

        setup_time = _r5(op.get("ISetUpTime") or 0.0)
        run_time = _r5(op.get("IRunTime") or 0.0)
        startup_time = _r5(op.get("IStartupTime") or 0.0)
        teardown_time = _r5(op.get("ITeardownTime") or 0.0)
        unit_capacity = _r5(op.get("IUnitCapacity") or 0.0)

        labor = (
            _r5(run_time * run_rate)
            + _r5(setup_time * setup_rate / ebq)
            + _r5(startup_time * startup_rate / ebq)
            + _r5(teardown_time * teardown_rate / ebq)
        )
        fixed = _r5(unit_capacity * fixed_rate / ebq)
        variable = _r5(unit_capacity * variable_rate / ebq)
        subcontract = 0.0
        if subcontract_flag == "Y":
            subcontract = _r5(op.get("SubOpUnitValue") or op.get("SubWhatIfValue") or 0.0)

        breakdown = breakdown.add(CostBreakdown(labor=labor, fixed=fixed, variable=variable))
        if subcontract:
            breakdown = breakdown.add(CostBreakdown(material=subcontract))

        lines.append(
            OperationLine(
                operation=str(op.get("Operation") or ""),
                work_centre=str(op.get("WorkCentre") or "").strip(),
                rate_ind=rate_ind,
                labor=labor,
                fixed=fixed,
                variable=variable,
                subcontract=subcontract,
                setup_time=setup_time,
                run_time=run_time,
                startup_time=startup_time,
                teardown_time=teardown_time,
                unit_capacity=unit_capacity,
            )
        )

    return breakdown, tuple(lines)


def calculate_stock_cost(
    stock_code: str,
    route: str = "0",
    batch_qty: float | int | str | None = None,
    _stack: Tuple[str, ...] = (),
    _memo: Dict[str, Tuple[CostBreakdown, List[ComponentLine], List[OperationLine]]] | None = None,
) -> Tuple[CostBreakdown, List[ComponentLine], List[OperationLine]]:
    stock_code = _norm(stock_code)
    if _memo is None:
        _memo = {}
    if stock_code in _memo:
        return _memo[stock_code]
    if stock_code in _stack:
        leaf = _leaf_breakdown(stock_code)
        result = (leaf, [], [])
        _memo[stock_code] = result
        return result

    master = get_master(stock_code)
    parent_ebq = _effective_batch_qty(master, batch_qty)
    bom_rows = get_bom(stock_code, route)
    op_breakdown, op_lines = _operation_breakdown(stock_code, route, batch_qty)

    if not bom_rows and not op_lines:
        leaf = _leaf_breakdown(stock_code)
        result = (leaf, [], list(op_lines))
        _memo[stock_code] = result
        return result

    breakdown = CostBreakdown()
    component_lines: List[ComponentLine] = []

    for row in bom_rows:
        qty = Decimal(str(row.get("QtyPer") or row.get("QtyPerEnt") or 0.0)).quantize(Q6, rounding=ROUND_HALF_UP)
        if str(row.get("FixedQtyPerFlag") or "").strip().upper() == "Y":
            qty = Decimal(str(row.get("FixedQtyPer") or row.get("FixedQtyPerEnt") or qty)).quantize(Q6, rounding=ROUND_HALF_UP)
        else:
            scrap_qty = Decimal(str(row.get("ScrapQuantity") or row.get("ScrapQuantityEnt") or 0.0)).quantize(Q6, rounding=ROUND_HALF_UP)
            if scrap_qty != 0:
                qty = (qty + (scrap_qty / Decimal(str(parent_ebq)))).quantize(Q6, rounding=ROUND_HALF_UP)
            qty = (qty * (Decimal("1.0") + (Decimal(str(_r5(row.get("ScrapPercentage") or 0.0))) / Decimal("100.0")))).quantize(Q6, rounding=ROUND_HALF_UP)
        qty = float(qty)

        comp_code = str(row.get("Component") or "").strip()
        comp_wh = str(get_master(comp_code).get("WarehouseToUse", "") or "").strip() or str(row.get("Warehouse") or "").strip()
        child_breakdown = _component_breakdown(comp_code, comp_wh)
        scaled = child_breakdown.scale(qty)
        breakdown = breakdown.add(scaled)

        component_lines.append(
            ComponentLine(
                stock_code=comp_code,
                description=get_master(comp_code).get("Description", ""),
                warehouse=comp_wh,
                qty_per=float(
                    Decimal(str(row.get("QtyPer") or 0.0)).quantize(Q6, rounding=ROUND_HALF_UP)
                ),
                scrap_pct=_r5(row.get("ScrapPercentage") or 0.0),
                qty_required=qty,
                breakdown=scaled,
            )
        )

    result = (breakdown, component_lines, list(op_lines))
    _memo[stock_code] = result
    return result


def _component_qty(row: Dict, parent_ebq: float) -> float:
    qty = Decimal(str(row.get("QtyPer") or row.get("QtyPerEnt") or 0.0)).quantize(Q6, rounding=ROUND_HALF_UP)
    if str(row.get("FixedQtyPerFlag") or "").strip().upper() == "Y":
        qty = Decimal(str(row.get("FixedQtyPer") or row.get("FixedQtyPerEnt") or qty)).quantize(Q6, rounding=ROUND_HALF_UP)
    else:
        scrap_qty = Decimal(str(row.get("ScrapQuantity") or row.get("ScrapQuantityEnt") or 0.0)).quantize(Q6, rounding=ROUND_HALF_UP)
        if scrap_qty != 0:
            qty = (qty + (scrap_qty / Decimal(str(parent_ebq)))).quantize(Q6, rounding=ROUND_HALF_UP)
        qty = (qty * (Decimal("1.0") + (Decimal(str(_r5(row.get("ScrapPercentage") or 0.0))) / Decimal("100.0")))).quantize(Q6, rounding=ROUND_HALF_UP)
    return float(qty)


def calculate_tree_cost(
    stock_code: str,
    route: str = "0",
    batch_qty: float | int | str | None = None,
    _stack: Tuple[str, ...] = (),
    _memo: Dict[str, TreeNode] | None = None,
) -> TreeNode:
    stock_code = _norm(stock_code)
    if _memo is None:
        _memo = {}
    if stock_code in _memo:
        return _memo[stock_code]

    master = get_master(stock_code)
    warehouse = str(master.get("WarehouseToUse", "") or "").strip() if master else ""
    description = str(master.get("Description", "") or "").strip()
    ebq = _effective_batch_qty(master, batch_qty)

    if stock_code in _stack:
        leaf_breakdown = _leaf_breakdown(stock_code)
        node = TreeNode(
            stock_code=stock_code,
            description=description,
            warehouse=warehouse,
            route=_norm(route),
            ebq=ebq,
            bom_breakdown=leaf_breakdown,
            op_breakdown=CostBreakdown(),
        )
        _memo[stock_code] = node
        return node

    bom_rows = get_bom(stock_code, route)
    op_breakdown, op_lines = _operation_breakdown(stock_code, route, batch_qty)

    if not bom_rows and not op_lines:
        leaf_breakdown = _leaf_breakdown(stock_code)
        node = TreeNode(
            stock_code=stock_code,
            description=description,
            warehouse=warehouse,
            route=_norm(route),
            ebq=ebq,
            bom_breakdown=leaf_breakdown,
            op_breakdown=CostBreakdown(),
        )
        _memo[stock_code] = node
        return node

    bom_breakdown = CostBreakdown()
    components: List[TreeComponentLine] = []
    next_stack = _stack + (stock_code,)

    for row in bom_rows:
        comp_code = str(row.get("Component") or "").strip()
        comp_wh = str(get_master(comp_code).get("WarehouseToUse", "") or "").strip() or str(row.get("Warehouse") or "").strip()
        qty = _component_qty(row, ebq)
        child_node = calculate_tree_cost(comp_code, route, None, next_stack, _memo)
        line_breakdown = child_node.total_breakdown.scale(qty)
        bom_breakdown = bom_breakdown.add(line_breakdown)
        components.append(
            TreeComponentLine(
                stock_code=comp_code,
                description=str(get_master(comp_code).get("Description", "") or "").strip(),
                warehouse=comp_wh,
                qty_per=float(
                    Decimal(str(row.get("QtyPer") or row.get("QtyPerEnt") or 0.0)).quantize(Q6, rounding=ROUND_HALF_UP)
                ),
                scrap_pct=_r5(row.get("ScrapPercentage") or 0.0),
                qty_required=qty,
                breakdown=line_breakdown,
                node=child_node,
            )
        )

    node = TreeNode(
        stock_code=stock_code,
        description=description,
        warehouse=warehouse,
        route=_norm(route),
        ebq=ebq,
        bom_breakdown=bom_breakdown,
        op_breakdown=op_breakdown,
        components=components,
        operations=list(op_lines),
    )
    _memo[stock_code] = node
    return node


def format_report(
    stock_code: str,
    report_type: str = "What-if Costing Report",
    route: str = "0",
    batch_qty: float | int | str | None = None,
) -> str:
    return format_flat_report(stock_code, report_type=report_type, route=route, batch_qty=batch_qty)


def format_flat_report(
    stock_code: str,
    report_type: str = "What-if Costing Report",
    route: str = "0",
    batch_qty: float | int | str | None = None,
) -> str:
    master = get_master(stock_code)
    breakdown, components, operations = calculate_stock_cost(stock_code, route, batch_qty)
    warehouse = get_warehouse_cost(stock_code)
    effective_batch_qty = _effective_batch_qty(master, batch_qty)

    lines: List[str] = []
    lines.append("Prepared : 2026/04/17 11:49".ljust(43) + "PLASTI-EMPAQUES S.A.".ljust(35) + "Page : 1")
    lines.append("Version  : 6.1.033".ljust(43) + report_type)
    lines.append("")
    lines.append("-" * 133)
    lines.append(
        f"Stock code      Description                     U/m   Economic batch qty   W/h   Inventory cost   U/m   Pan size Rev Rel  Route"
    )
    lines.append(
        f"{stock_code:<15}{str(master.get('Description', '')).strip():<32}{str(master.get('StockUom', '')).strip():<6}{effective_batch_qty:>12.3f}{str(master.get('WarehouseToUse', '')).strip():>6}{_r5(warehouse.get('UnitCost') or warehouse.get('LastCostEntered') or 0.0):>15.5f}{str(master.get('StockUom', '')).strip():>6}{0.0:>10.3f}{str(master.get('Version', '')).strip():>4}{str(master.get('Release', '')).strip():>4}{_norm(route):>7}"
        )
    lines.append("")
    lines.append("Component      Description                     W/h  Quantity per       Material    Labor       Fixed        Variable     Total")

    for comp in components:
        lines.append(
            f"{comp.stock_code:<15}{comp.description[:29]:<29}{comp.warehouse:<4}{comp.qty_neta:>12.6f}{comp.breakdown.material:>13.5f}{comp.breakdown.labor:>11.5f}{comp.breakdown.fixed:>12.5f}{comp.breakdown.variable:>12.5f}{comp.total:>12.5f}"
        )

    lines.append("")
    lines.append(
        f"{'Cost of components :':<55}{breakdown.material:>13.5f}{breakdown.labor:>11.5f}{breakdown.fixed:>12.5f}{breakdown.variable:>12.5f}{breakdown.total:>12.5f}"
    )
    lines.append("")
    lines.append("Work center Description          Rate   Run   Setup   Startup  Teardown  Sub-contr.  Labor and set-up  Fixed OH   Variable OH   Total")
    for op in operations:
        lines.append(
            f"{op.operation:<4}{op.work_centre:<13}{op.rate_ind:>3}{op.run_time:>8.4f}{op.setup_time:>9.4f}{op.startup_time:>10.4f}{op.teardown_time:>10.4f}{op.subcontract:>12.5f}{op.labor:>16.5f}{op.fixed:>11.5f}{op.variable:>13.5f}{op.total:>12.5f}"
        )
    op_breakdown, _ = _operation_breakdown(stock_code, route, batch_qty)
    lines.append(
        f"{'Cost of operations :':<55}{op_breakdown.material:>13.5f}{op_breakdown.labor:>11.5f}{op_breakdown.fixed:>12.5f}{op_breakdown.variable:>12.5f}{op_breakdown.total:>12.5f}"
    )
    lines.append(
        f"{'Total what-if cost :':<55}{breakdown.material + op_breakdown.material:>13.5f}{breakdown.labor + op_breakdown.labor:>11.5f}{breakdown.fixed + op_breakdown.fixed:>12.5f}{breakdown.variable + op_breakdown.variable:>12.5f}{breakdown.total + op_breakdown.total:>12.5f}"
    )
    lines.append(
        f"{'B.O.M. cost        :':<55}{float(master.get('MaterialCost') or 0.0):>13.5f}{float(master.get('LabourCost') or 0.0):>11.5f}{float(master.get('FixOverhead') or 0.0):>12.5f}{float(master.get('VariableOverhead') or 0.0):>12.5f}{(float(master.get('MaterialCost') or 0.0)+float(master.get('LabourCost') or 0.0)+float(master.get('FixOverhead') or 0.0)+float(master.get('VariableOverhead') or 0.0)):>12.5f}"
    )
    lines.append("")
    lines.append("End of report")
    return "\n".join(lines)


def _format_tree_node(node: TreeNode, level: int = 0) -> List[str]:
    indent = "  " * level
    lines: List[str] = []
    lines.append(
        f"{indent}NODE L{level} {node.stock_code:<15}{node.description[:40]:<40} W/H {node.warehouse:<4} Route {_norm(node.route):<2} EBQ {node.ebq:>10.3f}"
    )
    lines.append(
        f"{indent}{'Components :':<16}{node.bom_breakdown.material:>13.5f}{node.bom_breakdown.labor:>11.5f}{node.bom_breakdown.fixed:>12.5f}{node.bom_breakdown.variable:>12.5f}{node.bom_breakdown.total:>12.5f}"
    )
    lines.append(
        f"{indent}{'Operations  :':<16}{node.op_breakdown.material:>13.5f}{node.op_breakdown.labor:>11.5f}{node.op_breakdown.fixed:>12.5f}{node.op_breakdown.variable:>12.5f}{node.op_breakdown.total:>12.5f}"
    )
    lines.append(
        f"{indent}{'Node total :':<16}{node.total_breakdown.material:>13.5f}{node.total_breakdown.labor:>11.5f}{node.total_breakdown.fixed:>12.5f}{node.total_breakdown.variable:>12.5f}{node.total_breakdown.total:>12.5f}"
    )
    lines.append(f"{indent}" + "-" * 118)
    if node.operations:
        lines.append(
            f"{indent}Op   Work center   Rate   Run      Setup    Startup  Teardown  Sub-contr.  Labor and set-up  Fixed OH   Variable OH   Total"
        )
        for op in node.operations:
            lines.append(
                f"{indent}{op.operation:<4}{op.work_centre:<13}{op.rate_ind:>3}{op.run_time:>8.4f}{op.setup_time:>9.4f}{op.startup_time:>10.4f}{op.teardown_time:>10.4f}{op.subcontract:>12.5f}{op.labor:>16.5f}{op.fixed:>11.5f}{op.variable:>13.5f}{op.total:>12.5f}"
            )
        lines.append(f"{indent}" + "-" * 118)
    for comp in node.components:
        lines.append(
            f"{indent}  -> {comp.stock_code:<15}{comp.description[:34]:<34}{comp.warehouse:<4} qty {comp.qty_neta:>12.6f}  {comp.breakdown.material:>13.5f}{comp.breakdown.labor:>11.5f}{comp.breakdown.fixed:>12.5f}{comp.breakdown.variable:>12.5f}{comp.total:>12.5f}"
        )
        if comp.node and (comp.node.components or comp.node.operations):
            lines.extend(_format_tree_node(comp.node, level + 1))
    return lines


def format_tree_report(
    stock_code: str,
    report_type: str = "What-if Costing Report",
    route: str = "0",
    batch_qty: float | int | str | None = None,
) -> str:
    master = get_master(stock_code)
    node = calculate_tree_cost(stock_code, route, batch_qty)
    warehouse = get_warehouse_cost(stock_code)
    effective_batch_qty = _effective_batch_qty(master, batch_qty)
    lines: List[str] = []
    lines.append("Prepared : 2026/04/17 11:49".ljust(43) + "PLASTI-EMPAQUES S.A.".ljust(35) + "Page : 1")
    lines.append("Version  : 6.1.033".ljust(43) + report_type + "  [TREE]")
    lines.append("")
    lines.append("-" * 133)
    lines.append(
        f"Stock code      Description                     U/m   Economic batch qty   W/h   Inventory cost   U/m   Pan size Rev Rel  Route"
    )
    lines.append(
        f"{stock_code:<15}{str(master.get('Description', '')).strip():<32}{str(master.get('StockUom', '')).strip():<6}{effective_batch_qty:>12.3f}{str(master.get('WarehouseToUse', '')).strip():>6}{_r5(warehouse.get('UnitCost') or warehouse.get('LastCostEntered') or 0.0):>15.5f}{str(master.get('StockUom', '')).strip():>6}{0.0:>10.3f}{str(master.get('Version', '')).strip():>4}{str(master.get('Release', '')).strip():>4}{_norm(route):>7}"
    )
    lines.append("")
    lines.extend(_format_tree_node(node, 0))
    lines.append("")
    lines.append(
        f"{'Total what-if cost :':<55}{node.total_breakdown.material:>13.5f}{node.total_breakdown.labor:>11.5f}{node.total_breakdown.fixed:>12.5f}{node.total_breakdown.variable:>12.5f}{node.total_breakdown.total:>12.5f}"
    )
    lines.append(
        f"{'B.O.M. cost        :':<55}{float(master.get('MaterialCost') or 0.0):>13.5f}{float(master.get('LabourCost') or 0.0):>11.5f}{float(master.get('FixOverhead') or 0.0):>12.5f}{float(master.get('VariableOverhead') or 0.0):>12.5f}{(float(master.get('MaterialCost') or 0.0)+float(master.get('LabourCost') or 0.0)+float(master.get('FixOverhead') or 0.0)+float(master.get('VariableOverhead') or 0.0)):>12.5f}"
    )
    lines.append("")
    lines.append("End of report")
    return "\n".join(lines)
