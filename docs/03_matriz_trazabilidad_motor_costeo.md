# Matriz de trazabilidad del motor de costeo

## Objetivo

Este documento conecta el conocimiento funcional con la implementacion real para que un programador nuevo pueda responder rapidamente estas preguntas:

- que regla de negocio existe
- en que tabla o campo se apoya
- en que archivo del codigo vive
- que salida afecta

La idea es evitar que el equipo tenga que releer todo el proyecto para ubicar una regla puntual.

## Como leer esta matriz

Cada fila conecta cinco cosas:

1. regla funcional
2. origen de datos en SYSPRO
3. implementacion en codigo
4. efecto en salida
5. notas para evolucion futura

## Matriz principal

| Regla o comportamiento | Tablas y campos base | Codigo actual | Salida afectada | Notas de continuidad |
|---|---|---|---|---|
| El item padre se toma desde maestro y define descripcion, `EBQ`, warehouse y contexto base | `InvMaster.StockCode`, `Description`, `Ebq`, `WarehouseToUse`, `StockUom` | `get_master()` en `src/cotizador_ia/bom_costing.py` | Cabecera del reporte y contexto del calculo | Toda nueva UI debe cargar primero este bloque canonico |
| El lote efectivo sale del valor recibido o, si no existe, de `InvMaster.Ebq` | `InvMaster.Ebq` | `_effective_batch_qty()` en `src/cotizador_ia/bom_costing.py` | Cantidades BOM, prorrateos operativos, total final | Esta regla debe quedar reusable para escenarios editables |
| La BOM del padre se lee por `ParentPart` y `Route` | `BomStructure.ParentPart`, `Route`, `Component`, `SequenceNum` | `get_bom()` en `src/cotizador_ia/bom_costing.py` | Lineas de componentes y arbol multinivel | Toda version futura debe preservar la ruta como parametro explicito |
| La cantidad base del componente sale de `QtyPer` o `QtyPerEnt` | `BomStructure.QtyPer`, `QtyPerEnt` | `calculate_stock_cost()` y `_component_qty()` en `src/cotizador_ia/bom_costing.py` | Columna `Quantity per` y costo material | No reemplazar esta formula con cantidades visuales sin trazabilidad |
| Si `FixedQtyPerFlag = Y`, la cantidad efectiva usa `FixedQtyPer` o `FixedQtyPerEnt` | `BomStructure.FixedQtyPerFlag`, `FixedQtyPer`, `FixedQtyPerEnt` | `calculate_stock_cost()` y `_component_qty()` | Cantidad efectiva y costo del componente | Campo obligatorio en cualquier editor de escenarios |
| `ScrapQuantity` se divide por `EBQ` del padre | `BomStructure.ScrapQuantity`, `ScrapQuantityEnt`, `InvMaster.Ebq` | `calculate_stock_cost()` y `_component_qty()` | Cantidad neta y total de materiales | Regla critica, no debe reinterpretarse como costo directo |
| `ScrapPercentage` se aplica despues del ajuste por `ScrapQuantity / EBQ` | `BomStructure.ScrapPercentage` | `calculate_stock_cost()` y `_component_qty()` | Cantidad neta visible y costo material | Ya validado contra SYSPRO; mantener este orden |
| La cantidad visible se redondea a 6 decimales | Cantidad derivada de BOM | `Q6`, `qty_neta`, `_component_qty()` | Impresion de componentes y arbol | Si cambia la precision, debe documentarse antes en `docs/` |
| El costo visible del componente en `What-if` sale de `InvWhatIfCost` por `StockCode + Warehouse` | `InvWhatIfCost.StockCode`, `Warehouse`, `WhatIfMatCost`, `WhatIfLabCost`, `WhatIfFixCost`, `WhatIfVarCost` | `get_whatif_cost()` y `_component_breakdown()` | Linea visible del componente en reporte plano | Esta es una regla de simulacion, no de costo historico BOM |
| Si no hay `What-if`, el motor cae a datos base del articulo o warehouse | `InvMaster.MaterialCost`, `LabourCost`, `FixOverhead`, `VariableOverhead`, `InvWarehouse.UnitCost`, `LastCostEntered` | `_leaf_breakdown()` y `get_warehouse_cost()` | Costo de hojas o fallback | Mantener separado el fallback de la logica principal `What-if` |
| Si `WhatIfMatCost` es cero, el componente puede permanecer en cero en la salida `What-if` | `InvWhatIfCost.WhatIfMatCost` | `_component_breakdown()` | Costo material visible del componente | Regla confirmada en validacion documental |
| Las operaciones se leen por `StockCode` y `Route` | `BomOperations.StockCode`, `Route`, `Operation`, `WorkCentre`, `WcRateInd` | `get_operations()` | Seccion de operaciones en reportes | Base para panel de operaciones en `Estimaciones` |
| El `WorkCentre` resuelve tasas operativas | `BomWorkCentre.WorkCentre`, `SetUpRateX`, `RunTimeRateX`, `FixOverRateX`, `VarOverRateX`, `StartupRateX`, `TeardownRateX` | `get_work_centre()` y `_get_rate()` | Labor, overhead fijo y variable | Si cambia la maquina, la UI debe volver a cargar estas tasas |
| El indice de tasa se toma desde `WcRateInd` | `BomOperations.WcRateInd` | `_operation_breakdown()` | Seleccion de rates y costo operativo | Debe exponerse como dato visible para diagnostico |
| Labor se calcula con run, setup, startup y teardown; varios tiempos se prorratean por `EBQ` | `BomOperations.IRunTime`, `ISetUpTime`, `IStartupTime`, `ITeardownTime`; tasas de `BomWorkCentre` | `_operation_breakdown()` | `Labor and set-up` y total de operaciones | Regla central para escenarios de capacidad y lote |
| Overhead fijo y variable dependen de `IUnitCapacity` y rates del centro | `BomOperations.IUnitCapacity`; `BomWorkCentre.FixOverRateX`, `VarOverRateX` | `_operation_breakdown()` | Columnas `Fixed OH` y `Variable OH` | Si se cambia la formula, comparar contra casos reales |
| Subcontrato se toma cuando la operacion esta marcada como subcontratada | `BomOperations.SubcontractFlag`, `SubOpUnitValue`, `SubWhatIfValue` | `_operation_breakdown()` | Columna `Sub-contr.` y total de operaciones | Debe permanecer separado de labor/overhead en la UI |
| En reporte plano, la linea del componente usa costo directo del componente y no costo recursivo del subensamble | `InvWhatIfCost` + `BomStructure` | `calculate_stock_cost()` | Reporte plano estilo SYSPRO | Esto alinea con la lectura `What-if` observada |
| En reporte arbol, el total del nodo si acumula hijos y operaciones | BOM multinivel + operaciones | `calculate_tree_cost()` y `TreeNode.total_breakdown` | Reporte arbol y total final del padre | Esta es la regla que debe alimentar el costo total de `Estimaciones` |
| La proteccion contra ciclos evita recursion infinita | Estructura BOM multinivel | `calculate_stock_cost()` y `calculate_tree_cost()` con `_stack` y `_memo` | Reporte arbol y estabilidad del motor | Mantener esta proteccion en cualquier refactor |
| El reporte plano y el reporte arbol son dos salidas distintas del mismo motor | Datos canonicos ya cargados | `format_flat_report()` y `format_tree_report()` | `outputs/*.txt` y consola | La UI futura debe reutilizar el mismo backend, no duplicarlo |
| El acceso a SQL Server se encapsula en el conector | Cadena de conexion y SQL | `connectors/syspro_sqlserver.py` | Toda lectura de datos | No mezclar SQL directo dentro de interfaces futuras |
| El script CLI genera reportes y guarda salida en `outputs/` | Parametros de linea de comandos | `scripts/generate_bom_costing_report.py` | Reportes de validacion manual | Util para regresion y soporte funcional |

## Trazabilidad para el programa Estimaciones

Estas relaciones son especialmente importantes para el desarrollo nuevo de `Estimaciones`:

| Necesidad de la pantalla | Regla base del motor | Impacto tecnico |
|---|---|---|
| Editar `EBQ` global | `_effective_batch_qty()` y formulas con `ScrapQuantity / EBQ` | El cambio debe recalcular todo el arbol |
| Cambiar maquina o `WorkCentre` | `get_work_centre()` + `_get_rate()` | Debe refrescar tasas automaticamente |
| Editar cantidades y scrap | `_component_qty()` | Debe recalcular cantidad neta y costo |
| Editar costo manual de un componente | hoy se resuelve en `_component_breakdown()` | Conviene introducir `overrides` por escenario sin tocar la lectura canonica |
| Mostrar costo total del nodo y del padre | `TreeNode.total_breakdown` | La UI debe apoyarse en salida arbol, no solo en reporte plano |
| Propagar cambios de subensambles repetidos | hoy la estructura se identifica por `stock_code` y memoizacion | Requiere diseño cuidadoso si un escenario permite overrides por instancia o por codigo |

## Archivos que un programador nuevo debe revisar primero

Orden recomendado:

1. `docs/02_conocimiento_motor_costeo.md`
2. `docs/09_guia_operativa_motor_costeo.md`
3. `docs/05_modelo_costeo_syspro.md`
4. `docs/10_estimaciones_v1_1_definicion_funcional.md`
5. `src/cotizador_ia/bom_costing.py`
6. `connectors/syspro_sqlserver.py`
7. `scripts/generate_bom_costing_report.py`

## Criterio de mantenimiento

Cuando cambie una regla del motor o se agregue una nueva:

1. actualizar primero esta matriz
2. actualizar luego el documento funcional o tecnico afectado
3. cambiar despues el codigo
4. validar contra un caso real

Este orden ayuda a que el conocimiento del proyecto no vuelva a dispersarse.
