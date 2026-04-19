# Conocimiento consolidado del motor de costeo

## Objetivo

Este documento existe para que el conocimiento del motor de costeo no se pierda y no haya que reconstruirlo desde cero en otro proyecto, por otra persona o en otra etapa del mismo desarrollo.

Su funcion es concentrar en un solo lugar:

- que hace el motor
- por que se implemento asi
- donde vive cada parte
- que datos consume
- que relaciones de base usa
- que entradas y salidas maneja
- como extenderlo sin romper la logica canonica

## Que problema resuelve

El proyecto necesita tomar un articulo padre de SYSPRO y reproducir su costo de manufactura con una logica alineada a la salida real del ERP, especialmente al reporte `What-if Costing Report`.

El motor no intenta reemplazar SYSPRO.

Su proposito es:

- leer la estructura real desde la base
- aplicar la logica de costeo confirmada en validacion
- producir una salida util para analisis, cotizacion y escenarios futuros

## Por que se hizo asi

Estas decisiones quedaron consolidadas durante la validacion del motor:

1. La fuente de verdad del negocio es SYSPRO y sus tablas reales, no estructuras inventadas por el proyecto.
2. La simulacion `What-if` y el costo `B.O.M. cost` no representan lo mismo, por eso se documentan y se calculan por separado.
3. La logica de materiales visible en `What-if` consume costo directo del componente desde `InvWhatIfCost`; no reconstruye recursivamente el costo visible de cada linea.
4. La acumulacion multinivel si existe para el total del arbol, por eso el motor separa costo visible de linea y costo acumulado del nodo.
5. La documentacion se mantiene en `docs/` para que el conocimiento del motor sobreviva aunque cambie el codigo, el formulario o el proyecto consumidor.

## Donde esta el conocimiento hoy

### Codigo principal

- `src/cotizador_ia/bom_costing.py`
- `connectors/syspro_sqlserver.py`
- `src/cotizador_ia/settings.py`
- `scripts/generate_bom_costing_report.py`
- `scripts/bom_costing_form.py`

### Documentacion principal

- `docs/09_guia_operativa_motor_costeo.md`
- `docs/05_modelo_costeo_syspro.md`
- `docs/06_mapa_lectura_syspro.md`
- `docs/07_tablas_syspro_en_uso.md`
- `docs/08_flujo_costeo_whatif_syspro.md`
- `docs/04_readme_tecnico_implementacion_syspromodel.md`
- `docs/10_estimaciones_v1_1_definicion_funcional.md`

## Arquitectura logica del motor

El motor esta organizado conceptualmente en capas:

1. Configuracion y acceso:
   - lectura de `.env`
   - resolucion de conexion SQL Server
2. Lectura canonica de datos:
   - item padre
   - BOM
   - operaciones
   - centros de trabajo
   - costos `What-if`
3. Reglas de costeo:
   - cantidades efectivas
   - scrap
   - cantidades fijas
   - costos de material
   - costos de operacion
   - acumulacion multinivel
4. Presentacion:
   - reporte plano estilo SYSPRO
   - reporte arbol
   - salida para formularios o escenarios editables

Regla importante:

- la lectura base de SYSPRO debe mantenerse canonica
- cualquier escenario editable debe aplicarse como `override` encima de esa base

## Base de datos y tablas clave

La base de trabajo documentada es:

- servidor: `192.168.1.5`
- base de datos: `EncorePlasti1`

Tablas principales del motor:

- `InvMaster`
- `InvWarehouse`
- `InvWhControl`
- `InvWhatIfCost`
- `BomStructure`
- `BomOperations`
- `BomWorkCentre`
- `BomCostCentre`
- `WipMaster`
- `WipJobAllMat`
- `WipJobAllLab`

## Relaciones funcionales de base

Las relaciones exactas deben validarse contra los scripts SQL del instalador y la base real, pero a nivel funcional el motor trabaja asi:

### Maestro y warehouse

- `InvMaster.StockCode` identifica el item padre o componente
- `InvWarehouse.StockCode + Warehouse` complementa contexto de costo por almacen
- `InvWhatIfCost.StockCode + Warehouse` aporta la simulacion usada por `What-if`

### BOM

- `BomStructure.ParentPart` o equivalente funcional relaciona el padre con sus componentes
- `BomStructure.Component` o equivalente funcional identifica el hijo
- el registro BOM aporta `QtyPer`, `ScrapPercentage`, `ScrapQuantity`, `FixedQtyPerFlag` y campos relacionados

### Ruta y centros de trabajo

- `BomOperations` relaciona articulo y ruta con operaciones
- `BomOperations.WorkCentre` conecta con `BomWorkCentre`
- `BomWorkCentre` y, cuando aplica, `BomCostCentre`, aportan tasas para labor y overhead

### Validacion operativa

- `WipMaster`, `WipJobAllMat` y `WipJobAllLab` no son la fuente del calculo canonico
- se usan para contrastar el modelo contra ejecucion real

## Input del motor

Las entradas minimas de negocio son:

- `ParentPart` o `StockCode` a costear
- `Warehouse` cuando el contexto lo requiere
- `BatchQty` o lote efectivo
- opcion de salida:
  - plano
  - arbol
  - simulacion visual

Entradas derivadas desde base:

- `EBQ`
- componentes BOM
- operaciones de ruta
- tasas de work centre
- costos `What-if`

## Output del motor

Las salidas principales son:

- costo total del padre
- costo total de materiales
- costo total de operaciones
- overhead fijo
- overhead variable
- subcontrato cuando exista
- detalle por componente
- detalle por operacion
- arbol BOM costeado
- reporte textual con layout estilo SYSPRO

En terminos de estructura de datos, el lector del modelo aspira a devolver bloques como:

- `item_master`
- `bom_components`
- `routing_operations`
- `work_centers`
- `what_if_cost`
- `warehouses`
- `system_settings`
- `calculated_vs_actual_cost`

## Flujo de procesamiento

La secuencia consolidada del motor es:

1. Leer configuracion y abrir conexion.
2. Buscar el item padre en `InvMaster`.
3. Resolver `EBQ` desde el lote recibido o desde el maestro.
4. Leer la estructura BOM del padre.
5. Calcular la cantidad efectiva de cada componente.
6. Leer el costo simulado del componente desde `InvWhatIfCost`.
7. Costear materiales directos.
8. Leer operaciones desde `BomOperations`.
9. Resolver tasas desde `BomWorkCentre` segun `WcRateInd` u otra configuracion aplicable.
10. Calcular labor, overhead fijo, overhead variable y subcontrato.
11. Acumular costo hacia arriba en el arbol.
12. Formatear la salida requerida.

## Reglas de negocio que no deben perderse

Estas reglas son parte del conocimiento duro del motor:

1. `ScrapQuantity` se divide por `EBQ`.
2. `ScrapPercentage` se aplica sobre la cantidad ya ajustada.
3. La cantidad efectiva visible se maneja con 6 decimales.
4. Si `WhatIfMatCost` es cero, la linea del componente se conserva en cero en la salida `What-if`.
5. La linea visible del componente en `What-if` usa costo directo del componente, no costo recursivo del subensamble.
6. El total arbol si debe acumular costos de niveles inferiores.
7. Debe mantenerse proteccion contra ciclos en la explosion multinivel.
8. `What-if` y `B.O.M. cost` no deben mezclarse al validar.

## Como se extiende sin romper el conocimiento

Si el proyecto evoluciona a escenarios editables o a otro producto:

1. no alterar la lectura canonica desde SYSPRO
2. agregar una capa de `overrides` en memoria
3. mantener separado:
   - dato fuente
   - regla de calculo
   - salida visual
4. documentar primero en `docs/` y luego cambiar codigo
5. actualizar antes que nada:
   - `07_tablas_syspro_en_uso.md`
   - `06_mapa_lectura_syspro.md`
   - `05_modelo_costeo_syspro.md`

## Documentos que preservan el conocimiento por tema

- `05_modelo_costeo_syspro.md`: define el modelo funcional general y las reglas de validacion principales
- `06_mapa_lectura_syspro.md`: documenta que se lee desde la base y que estructura de salida se espera
- `08_flujo_costeo_whatif_syspro.md`: explica el flujo operativo usado para reproducir la salida `What-if`
- `09_guia_operativa_motor_costeo.md`: concentra como leer, cambiar y validar el motor actual
- `10_estimaciones_v1_1_definicion_funcional.md`: traduce el motor a una futura interfaz de escenarios editables

## Recomendacion para no volver a empezar desde cero

Cuando alguien retome este trabajo, el orden recomendado es:

1. leer este documento
2. leer `docs/README.md`
3. leer `docs/09_guia_operativa_motor_costeo.md`
4. leer `docs/05_modelo_costeo_syspro.md`
5. leer `docs/06_mapa_lectura_syspro.md`
6. revisar el codigo en `src/cotizador_ia/bom_costing.py` y `connectors/syspro_sqlserver.py`
7. validar con un caso real como `9320000432`

## Estado del conocimiento

Si, el conocimiento del motor ya esta guardado en el repositorio, principalmente en `docs/`.

Lo que hacia falta era dejarlo menos disperso y mas facil de transferir. Este documento sirve precisamente como punto de entrada para conservar ese conocimiento entre proyectos y entre personas.
