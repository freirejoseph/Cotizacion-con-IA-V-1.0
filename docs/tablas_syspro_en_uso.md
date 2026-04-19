# Tablas SYSPRO en uso

Este documento se reconstruye desde cero usando solo los scripts instaladores oficiales de SYSPRO:

- `docs/Script SQL/SYSPRO61.SQL`
- `docs/Script SQL/SYSPRO61SP1.SQL`

Solo se documentan tablas y relaciones reales. Los objetos derivados del proyecto quedan fuera de este listado canonico.

Reglas de mantenimiento:

- Si se agregan nuevas tablas al proyecto, este archivo debe actualizarse primero.
- Si un nombre de tabla o campo cambia en la base real, la correccion se hace aqui primero.
- Los nombres que aparecen abajo son los del script real de SQL Server.

## 1. Canon SYSPRO de instalacion

### 1. `InvMaster`

Maestro de inventario. Es la tabla principal para identificar el articulo padre y leer sus atributos de costeo.

Campos clave:

- `StockCode`
- `Description`
- `LongDesc`
- `StockUom`
- `AlternateUom`
- `OtherUom`
- `ProductClass`
- `PartCategory`
- `TraceableType`
- `SerialMethod`
- `AbcCostingReq`
- `CostUom`
- `LabourCost`
- `MaterialCost`
- `FixOverhead`
- `VariableOverhead`
- `Ebq`
- `LeadTime`
- `ManufLeadTime`
- `PercentageYield`
- `WarehouseToUse`
- `StdLctRoute`
- `StdLandedCost`
- `StdLabCostsBill`
- `LctRequired`
- `EccFlag`
- `Release`
- `Version`
- `StockAndAltUm`
- `StockMovementReq`
- `DateStkAdded`
- `DateLastCostCange`

Uso:

- Definir el articulo a costear.
- Tomar el EBQ y costos base del articulo.
- Identificar si el item tiene trazabilidad, ECC o ruta estandar.

### 2. `InvWarehouse`

Existencia y costo por almacén.

Campos clave:

- `StockCode`
- `Warehouse`
- `QtyOnHand`
- `QtyAllocated`
- `QtyOnOrder`
- `QtyOnBackOrder`
- `QtyAllocatedWip`
- `QtyInTransit`
- `UnitCost`
- `LastCostEntered`
- `CostMultiplier`
- `DefaultBin`
- `DefaultSourceWh`
- `DateLastStockMove`
- `DateLastPurchase`
- `DateLastCostChange`
- `DateLastStockCnt`
- `SafetyStockQty`
- `ReOrderQty`
- `InterfaceFlag`

Uso:

- Obtener costo unitario por warehouse.
- Validar existencia disponible.
- Revisar costo actual y último costo registrado.

### 3. `InvWhControl`

Control del warehouse.

Campos clave:

- `Warehouse`
- `Description`
- `CostingMethod`
- `WipControlGlCode`
- `WipVarCtlGlCode`
- `WipAutoVarGlCode`
- `WipInspectGlCode`
- `Route`
- `RouteCode`
- `RouteDistance`
- `UseMultipleBins`
- `WmsActive`
- `InclPlanning`
- `StockTakeFlag`
- `NegStockAllow`

Uso:

- Resolver si el costeo depende del warehouse.
- Tomar reglas de control, bins y cuentas WIP asociadas al almacén.

### 4. `BomStructure`

Estructura padre/componente.

Campos clave:

- `ParentPart`
- `Component`
- `Version`
- `ComVersion`
- `Release`
- `ComRelease`
- `Route`
- `SequenceNum`
- `StructureOnDate`
- `StructureOffDate`
- `QtyPer`
- `ScrapPercentage`
- `ScrapQuantity`
- `FixedQtyPerFlag`
- `FixedQtyPer`
- `OpOffsetFlag`
- `OperationOffset`
- `InclScrapFlag`
- `InclKitIssues`
- `CreateSubJob`
- `IncludeBatch`
- `IncludeFromJob`
- `IncludeToJob`
- `RollUpCost`
- `Warehouse`
- `UomFlag`
- `QtyPerEnt`
- `ScrapQuantityEnt`
- `FixedQtyPerEnt`
- `CoProductCostVal`

Uso:

- Calcular materiales por nivel de BOM.
- Aplicar scrap y cantidad fija.
- Detectar vigencia de la estructura.

### 5. `BomOperations`

Operaciones de manufactura ligadas al stock code.

Campos clave:

- `StockCode`
- `Version`
- `Release`
- `Route`
- `Operation`
- `WorkCentre`
- `SubcontractFlag`
- `ISetUpTime`
- `IRunTime`
- `IStartupTime`
- `ITeardownTime`
- `IWaitTime`
- `IStartupQty`
- `IUnitCapacity`
- `IMaxWorkOpertrs`
- `IMaxProdUnits`
- `ITimeTaken`
- `IQuantity`
- `SubSupplier`
- `SubPoStockCode`
- `SubQtyPer`
- `SubOrderUom`
- `SubOpUnitValue`
- `SubWhatIfValue`
- `SubPlanner`
- `SubBuyer`
- `SubLeadTime`
- `SubDockToStock`
- `SubOffsiteDays`
- `ElapsedTime`
- `MovementTime`
- `MinorSetup`
- `MinorSetupCode`
- `ToolSet`
- `ToolSetQty`
- `ToolConsumption`
- `TimeCalcFlag`
- `OperYieldPct`
- `OperYieldQty`
- `TransferQtyOrPct`
- `TransferQtyPct`
- `CoProductCostVal`
- `AllowOpSplit`

Uso:

- Calcular tiempos de set up, corrida, startup y teardown.
- Identificar subcontrato.
- Obtener la secuencia operativa y su centro de trabajo.

### 6. `BomWorkCentre`

Centro de trabajo asociado a la operacion.

Campos clave:

- `WorkCentre`
- `Description`
- `CostCentre`
- `SetUpRate1` a `SetUpRate9`
- `RunTimeRate1` a `RunTimeRate9`
- `FixOverRate1` a `FixOverRate9`
- `VarOverRate1` a `VarOverRate9`
- `StartupRate1` a `StartupRate9`
- `TeardownRate1` a `TeardownRate9`
- `TimeUom`
- `EtCalcMeth`
- `CapacityUom`
- `CstToCapFact`
- `CstToCapMulDiv`
- `ProdUnitDesc`
- `SubcontractFlag`
- `UseEmployeeRate`
- `ProductClass`
- `RunTime`
- `SetupTime`
- `FixTime`
- `VarTime`
- `StartTime`
- `TeardownTime`
- `NonRunTime`
- `NonSetupTime`
- `NonFixTime`
- `NonVarTime`
- `NonStartTime`
- `NonTearTime`

Uso:

- Tomar rates para costo de operacion y overhead.
- Relacionar la operacion con el cost center.
- Aplicar la logica de conversion entre costo y capacidad.

### 7. `BomCostCentre`

Centro de costo del BOM.

Campos clave:

- `CostCentre`
- `Description`
- `SetUpRate1` a `SetUpRate9`
- `RunTimeRate1` a `RunTimeRate9`
- `FixOverRate1` a `FixOverRate9`
- `VarOverRate1` a `VarOverRate9`
- `StartupRate1` a `StartupRate9`
- `TeardownRate1` a `TeardownRate9`
- `TimeUom`
- `EtCalcMeth`
- `CapacityUom`
- `CstToCapFact`
- `CstToCapMulDiv`
- `ProdUnitDesc`
- `SubcontractFlag`
- `UseEmployeeRate`
- `ProductClass`
- `RunTime`
- `SetupTime`
- `FixTime`
- `VarTime`
- `StartTime`
- `TeardownTime`
- `NonRunTime`
- `NonSetupTime`
- `NonFixTime`
- `NonVarTime`
- `NonStartTime`
- `NonTearTime`

Uso:

- Servir como base de tasas para el costo calculado.
- Soportar comparacion entre el costeo por centro y por operacion.

### 8. `WipMaster`

Cabecera de job o WIP.

Campos clave:

- `Job`
- `JobDescription`
- `JobClassification`
- `JobType`
- `MasterJob`
- `StockCode`
- `Warehouse`
- `Customer`
- `CustomerName`
- `JobTenderDate`
- `JobDeliveryDate`
- `JobStartDate`
- `ActCompleteDate`
- `Complete`
- `DateCalcMethod`
- `ExpLabour`
- `ExpMaterial`
- `QtyToMake`
- `QtyManufactured`
- `Source`
- `EstSourceNum`
- `SalesOrder`
- `Route`
- `WipCtlGlCode`
- `AddLabPct`
- `AddMatPct`
- `ProfitPct`
- `MaterialBilled`
- `LabourBilled`
- `TotalQtyScrapped`
- `ConfirmedFlag`
- `HoldFlag`
- `JobCreatedStruc`
- `TraceableType`

Uso:

- Validar jobs abiertos o cerrados.
- Comparar estimados contra reales.
- Servir como cabecera para materiales y mano de obra del WIP.

### 9. `WipJobAllMat`

Asignaciones de material para el job.

Campos clave:

- `Job`
- `StockCode`
- `Warehouse`
- `Line`
- `StockDescription`
- `UnitQtyReqd`
- `UnitCost`
- `OperationOffset`
- `OpOffsetFlag`
- `Uom`
- `Bin`
- `QtyIssued`
- `ValueIssued`
- `QtyBilled`
- `ValueBilled`
- `SequenceNum`
- `PhantomParent`
- `ApplyCostUom`
- `CostUom`
- `BulkIssueItem`
- `ScrapPercentage`
- `ScrapQuantity`
- `FixedQtyPerFlag`
- `FixedQtyPer`
- `NetUnitQtyReqd`
- `RollUpCostFlag`
- `CoProductCostVal`

Uso:

- Validar consumo real o planificado de materiales.
- Comparar unit qty requerida contra consumida.

### 10. `WipJobAllLab`

Asignaciones de mano de obra y operacion para el job.

Campos clave:

- `Job`
- `Operation`
- `SubcontractOp`
- `IMachine`
- `IExpUnitRunTim`
- `IExpSetUpTime`
- `IExpStartupTime`
- `IExpShutdownTim`
- `IWaitTime`
- `IWcRateInd`
- `IStartupQty`
- `ICapacityReqd`
- `IMaxWorkOpertrs`
- `IMaxProdUnits`
- `SubSupplier`
- `SupPoStkCode`
- `SubQtyPer`
- `SubOrderUom`
- `SubUnitValue`
- `UnitValueReqd`
- `RunTimeIssued`
- `SetUpIssued`
- `StartUpIssued`
- `ShutdownIssued`
- `ValueIssued`
- `ValueBilled`
- `OperCompleted`
- `QtyCompleted`
- `QtyScrapped`
- `WorkCentre`
- `WorkCentreDesc`
- `ElapsedTime`
- `MovementTime`
- `QueueTime`
- `ToolSet`
- `ToolSetQty`
- `ToolConsumption`
- `ParentQtyPlanned`
- `OperYieldPct`
- `OperYieldQty`
- `ParIssQty`
- `HoursBilled`
- `CoProductCostVal`

Uso:

- Comparar la mano de obra real vs la calculada.
- Verificar tiempos, consumos y sobrecargos por operacion.

## 2. Tablas de reconciliacion en `EncorePlasti1 Script SQL.sql`

Estas tablas aparecen en el script completo de `EncorePlasti1` y complementan la base de costeo y su validacion.

### 11. `BomRoute`

Cabecera de rutas de fabricacion.

Uso:

- identificar la ruta definida para el articulo.
- validar que `Route 0` exista y sea la ruta de referencia.

### 12. `BomCapacity`

Capacidad del centro de trabajo.

Uso:

- apoyar la validacion de capacidad y carga asociada a `BomWorkCentre`.

### 13. `BomSchedGroup` y `BomSchedGroupDet`

Grupos de programacion y su detalle.

Uso:

- complementar la planificacion de manufactura cuando una ruta o centro lo requiera.

### 14. `InvMasterUom`

Unidades alternativas de inventario.

Uso:

- validar conversiones de unidad cuando el articulo no se consume en la U/M base.

### 15. `WipControl`

Control general de WIP.

Uso:

- revisar parametros globales de manufactura y acumulacion de costo.

### 16. `WipPartBook`

Registro de partes/libros de WIP.

Uso:

- soporte de validacion para costo y movimiento de partes en proceso.

### 17. `WipDistrMat`

Distribucion de materiales en WIP.

Uso:

- contrastar materiales emitidos contra la estructura calculada.

### 18. `WipJobPost`

Posteo de consumos y mano de obra de jobs.

Uso:

- validar el cruce entre el costo planeado y el costo efectivamente contabilizado.

## 3. Tablas de validacion del What-if

### `InvWhatIfCost`

Tabla de validacion para la simulacion `What-if` en la base actual.

Campos clave:

- `StockCode`
- `Warehouse`
- `WhatIfMatCost`
- `WhatIfLabCost`
- `WhatIfFixCost`
- `WhatIfVarCost`
- `WhatIfSubContCost`

Uso:

- Fuente directa del costo simulado por componente.
- Base para el reporte `What-if Costing Report`.
- Validacion de cantidades efectivas y costo por warehouse.
- Su origen se mantiene como dependencia de validacion hasta confirmar su inclusion formal en el instalador original.

## Tablas fuera del primer corte

No entran aun al modelo base de costeo:

- `SalTargets`
- `SalHistorySummary`
- `SorMaster`
- `SorDetail`
- `ArCustomer`
- `SalProductClass`
- `SalSalesperson`
- `InvMovements`
- `InvAltStock`
- Views de analitica o reporte que no sean parte directa del costeo

## Criterio de ampliacion

Cuando una nueva tabla pase a ser necesaria para el cotizador, se agrega aqui primero y luego se incorpora al codigo o a los queries.
