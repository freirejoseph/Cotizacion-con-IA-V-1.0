# Flujo detallado de costeo What-if en SYSPRO

Este documento explica el flujo operativo que usamos para reproducir la salida `What-if Costing Report` de SYSPRO y validar el cotizador contra la base real de `EncorePlasti1`.

Canon documental:

- `docs/Script SQL/SYSPRO61.SQL`
- `docs/Script SQL/SYSPRO61SP1.SQL`

Este flujo usa solo tablas reales y relaciones del instalador oficial. Cualquier objeto auxiliar del proyecto queda fuera del canon.

## 1. Objetivo

Reproducir la simulacion de costos que SYSPRO muestra cuando el usuario selecciona:

- `Cost based on`
  - `Inventory`
  - `Ult. costo`
  - `Simulacion`
  - `BOM`
- `Cost to update`
  - `BOM`
  - `BOM and What-if`
  - `Simulacion`

Para el proyecto, el flujo inicial se centra en:

- `Route 0`
- reporte `What-if Costing Report`
- validacion de materiales, labor y overhead

## 2. Entradas del flujo

El flujo requiere:

- `ParentPart`
- `Route`
- warehouse de referencia
- opcion de costeo: `What-if`
- opcion de actualizacion: solo documental por ahora

Tablas principales:

- `InvMaster`
- `InvWarehouse`
- `InvWhatIfCost`
- `BomStructure`
- `BomOperations`
- `BomWorkCentre`

Tablas de referencia:

- `WipMaster`
- `WipJobAllMat`
- `WipJobAllLab`

## 3. Secuencia operativa

### Paso 1. Leer el articulo padre

Se obtiene desde `InvMaster`:

- `StockCode`
- `Description`
- `Ebq`
- `WarehouseToUse`
- `MaterialCost`
- `LabourCost`
- `FixOverhead`
- `VariableOverhead`

### Paso 2. Fijar la ruta

Para validacion se usa `Route 0`.

Esto evita ambiguedades y permite comparar exactamente contra la captura de SYSPRO.

### Paso 3. Leer la BOM

Se extrae `BomStructure` para el padre y la ruta.

Campos clave:

- `QtyPer`
- `QtyPerEnt`
- `ScrapPercentage`
- `ScrapQuantity`
- `FixedQtyPerFlag`
- `FixedQtyPer`
- `FixedQtyPerEnt`
- `Warehouse`
- `UomFlag`
- `RollUpCost`

### Paso 4. Calcular la cantidad efectiva

Regla confirmada en validacion:

- la cantidad se conserva con 6 decimales
- `ScrapQuantity` se divide por `EBQ`
- `ScrapPercentage` se aplica despues
- si `FixedQtyPerFlag = Y`, se usa la cantidad fija

Formula operativa:

```text
qty_neta = qty_per + scrap_quantity / EBQ
qty_neta = qty_neta * (1 + scrap_percentage / 100)
```

### Paso 5. Leer el costo What-if del componente

La fuente real del costo visible del componente es `InvWhatIfCost`.

Campos:

- `WhatIfMatCost`
- `WhatIfLabCost`
- `WhatIfFixCost`
- `WhatIfVarCost`

Regla observada:

- si `WhatIfMatCost = 0`, la linea se mantiene en cero
- el reporte no infiere automaticamente otro costo para esa linea

### Paso 6. Multiplicar cantidad por costo

```text
material_line_cost = qty_neta * WhatIfMatCost
```

### Paso 7. Leer operaciones

Se extrae `BomOperations` por stock code y ruta.

Campos clave:

- `Operation`
- `WorkCentre`
- `WcRateInd`
- `ISetUpTime`
- `IRunTime`
- `IStartupTime`
- `ITeardownTime`
- `IUnitCapacity`
- `SubcontractFlag`
- `SubOpUnitValue`
- `SubWhatIfValue`

### Paso 8. Resolver tasas del work centre

Se usa `BomWorkCentre` para:

- `SetUpRate1` a `SetUpRate9`
- `RunTimeRate1` a `RunTimeRate9`
- `FixOverRate1` a `FixOverRate9`
- `VarOverRate1` a `VarOverRate9`
- `StartupRate1` a `StartupRate9`
- `TeardownRate1` a `TeardownRate9`

### Paso 9. Calcular operaciones

El costo de operacion se separa en:

- labor
- overhead fijo
- overhead variable
- subcontrato, si aplica

### Paso 10. Construir la salida

El reporte final debe mostrar:

- cabecera del padre
- componentes con cantidad efectiva
- costo de componentes
- operaciones
- costo de operaciones
- total `what-if`
- `B.O.M. cost` como referencia separada

## 4. Reglas confirmadas en SYSPRO

### Cantidades

- `QtyPer` debe leerse con 6 decimales
- `ScrapPercentage` se aplica sobre la cantidad ajustada
- `ScrapQuantity` puede dominar la cantidad efectiva en ciertos componentes

### Costos

- `WhatIfMatCost` es la fuente de la linea visible
- el costo historico del BOM no debe reemplazar la simulacion
- `WhatIfMatCost = 0` se conserva en cero

### Ruta

- la validacion de referencia usa `Route 0`
- no debemos asumir otra ruta mientras no se compare contra SYSPRO

### Recursividad

- no se detectaron ciclos directos en el caso de prueba `9320000432`
- la diferencia de costeo proviene de la consolidacion de costos, no de una recursion infinita

## 5. Salidas esperadas

El flujo debe entregar:

- reporte textual tipo SYSPRO
- detalle por componente
- detalle por operacion
- total `what-if`
- base documental para nuevas pruebas

## 6. Como se usa este flujo en el proyecto

1. Se toma un `ParentPart`.
2. Se fija `Route 0`.
3. Se corre el motor de costeo.
4. Se compara contra la captura de SYSPRO.
5. Si hay diferencia, se baja una rama del arbol BOM.
6. Se documenta el hallazgo en `docs/`.

## 7. Relacion con el resto de la documentacion

Este flujo se complementa con:

- `05_modelo_costeo_syspro.md`
- `06_mapa_lectura_syspro.md`
- `07_tablas_syspro_en_uso.md`
- `04_readme_tecnico_implementacion_syspromodel.md`
