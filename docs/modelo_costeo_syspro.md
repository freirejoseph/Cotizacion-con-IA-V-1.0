# Modelo de costeo SYSPRO para el cotizador

Este documento define el modelo funcional que vamos a usar para construir el programa de costeo y cotizacion sobre SYSPRO.

La base documental del proyecto vive en `docs/` y se actualiza con estos insumos:

- `Documentacion sobre Costeo.pdf`
- `docs/Script SQL/SYSPRO61.SQL`
- `docs/Script SQL/SYSPRO61SP1.SQL`
- `docs/Script SQL/EncorePlasti1 Script SQL.sql`
- `tablas_syspro_en_uso.md`
- `mapa_lectura_syspro.md`
- `README_tecnico_implementacion_syspromodel.md`
- `flujo_costeo_whatif_syspro.md`
- `Tablas de SYSPRO ERP.pdf` como apoyo visual
- `Posible Recursividad.pdf` como apoyo de validacion

## Objetivo del modelo

Construir un flujo que permita:

1. Definir el esquema de conexion a SYSPRO.
2. Mapear tablas y campos reales para articulo, BOM y rutas.
3. Implementar una primera version del calculo de componentes.
4. Validar operaciones y overhead contra un ejemplo real de SYSPRO.

## Alcance funcional

El cotizador debe poder tomar un articulo padre y reconstruir su costo a partir de:

- maestro de articulo
- estructura BOM
- operaciones de fabricacion
- centros de trabajo
- costos por warehouse
- datos de WIP para validacion

El primer corte del modelo se enfoca en costeo de manufactura. No incluye todavia:

- ventas
- cuentas por cobrar
- clientes
- analitica comercial
- reportes fuera del costeo

## Esquema de conexion a SYSPRO

La conexion de trabajo apunta a:

- Servidor: `192.168.1.5`
- Base de datos: `EncorePlasti1`
- Tipo de autenticacion: SQL Server

La configuracion debe vivir fuera de la logica de negocio y ser consumida por el conector de datos.

## Escenario funcional del costeo

Las pruebas de campo muestran que SYSPRO separa el proceso en dos capas:

- `Cost based on`
  - `Inventory`
  - `Ult. costo`
  - `Simulacion`
  - `BOM`
- `Cost to update`
  - `BOM`
  - `BOM and What-if`
  - `Simulacion`

Para este proyecto, el primer objetivo es reproducir la lectura `What-if Costing Report` usando `Route 0`, porque esa salida representa la simulacion que valida:

- cantidades por componente
- scrap
- costo por warehouse
- costos de operacion
- overhead fijo y variable

La impresion `B.O.M. cost` se trata como referencia base/historica y no debe mezclarse con la simulacion `What-if`.

## Tablas reales que sostienen el modelo

Las tablas base fueron tomadas del script SQL real generado desde `EncorePlasti1`.

### Maestro y existencias

- `InvMaster`
- `InvWarehouse`
- `InvWhControl`

### Estructura y ruta

- `BomStructure`
- `BomOperations`
- `BomWorkCentre`
- `BomCostCentre`

### Validacion de WIP

- `WipMaster`
- `WipJobAllMat`
- `WipJobAllLab`

## Mapa funcional de lectura

### 1. Articulo padre

Fuente principal:

- `InvMaster`

Datos relevantes:

- codigo del articulo
- descripcion corta y larga
- unidad de medida
- EBQ
- clase de producto
- categoria de parte
- tipo de trazabilidad
- revision / release
- costos base del articulo
- warehouse por defecto

Uso:

- identificar el articulo a costear
- obtener su unidad base
- leer su contexto de costeo antes de explotar BOM y rutas

### 2. Componentes BOM

Fuente principal:

- `BomStructure`

Datos relevantes:

- padre
- componente
- version
- release
- ruta
- secuencia
- vigencia desde / hasta
- cantidad por
- scrap %
- scrap cantidad
- cantidad fija
- warehouse
- indicadores de co-producto o subjob

Uso:

- reconstruir la lista de materiales
- calcular consumo por componente
- propagar scrap y cantidades fijas
- respetar vigencia de estructura

### 2.1 Lectura What-if / Simulacion

En la salida de validacion, la linea visible del componente no se reconstruye de forma recursiva. La logica efectiva es:

- leer `InvWhatIfCost` por `StockCode` y `Warehouse`
- usar `WhatIfMatCost` como costo material visible del componente
- conservar `0` cuando `WhatIfMatCost` es cero
- calcular la cantidad con 6 decimales antes de multiplicar
- aplicar `QtyPer`, `QtyPerEnt`, `ScrapPercentage`, `ScrapQuantity`, `FixedQtyPerFlag` y `FixedQtyPer`

Eso reproduce el comportamiento observado en las pruebas de `9320000432`, `5503200432`, `5603200432`, `56532L0432` y `56532R0432`.

### 3. Operaciones

Fuente principal:

- `BomOperations`

Datos relevantes:

- articulo
- ruta
- operacion
- work centre
- tiempos de setup, run, startup, teardown y espera
- indicador de subcontrato
- cantidad de inicio
- capacidad
- rendimiento
- transferencia por cantidad o porcentaje

Uso:

- calcular costo de mano de obra y carga de fabrica
- separar operaciones internas de subcontratadas
- distribuir el costo segun la logica de tiempo y EBQ

### 4. Centros de trabajo y tasas

Fuentes principales:

- `BomWorkCentre`
- `BomCostCentre`

Datos relevantes:

- codigo de centro
- descripcion
- cost centre relacionado
- tasas de setup, run, overhead fijo, overhead variable, startup y teardown
- unidad de tiempo
- conversion de costo a capacidad
- tipo de centro

Uso:

- obtener las tasas que alimentan el costo de operacion
- validar que el work centre tenga la configuracion correcta
- cruzar el centro de trabajo con el cost centre cuando aplique

### 5. Warehouse y control

Fuentes principales:

- `InvWarehouse`
- `InvWhControl`

Datos relevantes:

- stock code
- warehouse
- cantidad disponible
- costo unitario
- costo ultimo registrado
- metodo de costeo
- reglas de bins
- reglas WIP
- control de stock negativo

Uso:

- obtener costo por almacen
- validar existencia y costo actual
- respetar la politica del warehouse en el calculo

### 5.1 Costos What-if

Tabla clave para la simulacion en la base actual de validacion:

- `InvWhatIfCost`

Campos relevantes:

- `StockCode`
- `Warehouse`
- `WhatIfMatCost`
- `WhatIfLabCost`
- `WhatIfFixCost`
- `WhatIfVarCost`
- `WhatIfSubContCost`

Uso:

- fuente directa del costo simulado por componente
- base para el reporte `What-if Costing Report`
- validacion de materiales, labor y overhead por warehouse

Importante:

- solo las tablas y relaciones reales de `docs/Script SQL/SYSPRO61.SQL` y `docs/Script SQL/SYSPRO61SP1.SQL` definen la fuente oficial
- cualquier objeto derivado del proyecto queda fuera del modelo canonico
- `InvWhatIfCost` se usa en la base actual para validar el simulador `What-if`, pero queda marcado como dependencia de validacion hasta reconciliarlo de forma formal con el instalador original

### 6. Validacion de WIP

Fuentes principales:

- `WipMaster`
- `WipJobAllMat`
- `WipJobAllLab`

Datos relevantes:

- job
- articulo
- warehouse
- operaciones
- materiales emitidos
- mano de obra emitida
- cantidad producida
- cantidad scrap
- valor emitido
- valor facturado
- tiempos reales

Uso:

- comparar calculo estimado vs ejecucion real
- validar materiales y mano de obra
- detectar diferencias de overhead y rendimiento

## Primera version del calculo de componentes

La primera version del motor debe seguir esta secuencia para reproducir el reporte `What-if Costing Report` de SYSPRO:

1. Leer el articulo padre desde `InvMaster`.
2. Buscar su estructura en `BomStructure`.
3. Leer la cantidad requerida por componente con precision de 6 decimales.
4. Ajustar por `ScrapPercentage` y `ScrapQuantity`.
5. Respetar `FixedQtyPerFlag` cuando aplique.
6. Tomar el costo del componente desde `InvWhatIfCost` segun el warehouse del articulo.
7. Multiplicar la cantidad efectiva por el costo `WhatIf` del componente.
8. Acumular el costo total de materiales.
9. Calcular las operaciones desde `BomOperations` y `BomWorkCentre`.
10. Sumar el total `what-if` por material, labor, overhead fijo y variable.

### Regla base de materiales

Para cada componente:

- `qty_neta = qty_por + scrap_quantity / EBQ + ajuste_por_scrap`
- `material_cost = qty_neta * whatif_mat_cost`

Si `WhatIfMatCost` es cero, el componente se deja en cero para mantener la misma lectura del reporte de SYSPRO.

En las pruebas reales se confirmo que:

- `QtyPer` debe conservarse con 6 decimales antes de costear
- `ScrapQuantity` se divide por el `EBQ` del padre
- `ScrapPercentage` se aplica despues
- la linea del componente debe imprimir la cantidad efectiva, no la base

Si el componente tiene cantidad fija:

- el ajuste debe respetar la logica de `FixedQtyPerFlag`
- el consumo no debe tratarse como simple multiplicacion lineal sin validar la estructura

### Fuente real de costo

Para esta primera version, el reporte de simulacion usa:

- `InvWhatIfCost.WhatIfMatCost`
- `InvWhatIfCost.WhatIfLabCost`
- `InvWhatIfCost.WhatIfFixCost`
- `InvWhatIfCost.WhatIfVarCost`

La logica del reporte no debe reconstruir recursivamente el costo de subensambles para la linea visible del componente; debe consumir el costo `WhatIf` directo del articulo tal como lo hace SYSPRO en esta salida.

### Salida esperada

- costo total de materiales
- costo por componente
- arbol de explosion de BOM
- nivel de cada componente dentro de la estructura

## Operaciones y overhead

La segunda version del modelo debe validar la ruta de fabricacion y su costo asociado.

### Flujo de calculo

1. Leer operaciones desde `BomOperations`.
2. Resolver el `WorkCentre`.
3. Tomar tasas desde `BomWorkCentre` o `BomCostCentre`.
4. Calcular costo por tiempo de:
   - setup
   - run
   - startup
   - teardown
5. Agregar costo de subcontrato cuando exista.
6. Sumar overhead fijo y variable segun la configuracion del centro.

### Variables de trabajo

- `EBQ`: economic batch quantity
- `PU`: productive units
- `setup_time`
- `run_time`
- `startup_time`
- `teardown_time`
- `fixed_rate`
- `variable_rate`

### Resultado esperado

- costo de operacion por ruta
- costo de overhead por operacion
- costo total de fabricacion por articulo

### 6.4 Separacion entre `What-if` y `B.O.M. cost`

Durante la validacion se observo que SYSPRO imprime:

- `What-if Costing Report`
- `B.O.M. cost`

La primera salida usa los valores simulados `WhatIf`.
La segunda representa el costo BOM base/historico que SYSPRO muestra como referencia.

Para no mezclar conceptos:

- el cotizador valida primero `What-if`
- `B.O.M. cost` se documenta aparte
- no se usa `B.O.M. cost` para juzgar la precision del simulador

## Validacion contra WIP

Antes de dar el modelo por bueno, se debe contrastar con datos reales de ejecucion.

La validacion debe revisar:

- materiales planificados vs emitidos
- mano de obra planificada vs registrada
- tiempos estimados vs tiempos reales
- costo calculado vs costo acumulado en WIP

Las tablas de WIP no reemplazan al modelo de costeo; se usan como referencia para confirmar que el calculo esta alineado con la realidad de SYSPRO.

## Validacion de recursividad

En el caso de prueba `9320000432` con `Route 0`, el arbol BOM revisado en la base no mostro ciclos.

Hallazgo:

- no se encontro una recursividad directa en la ruta de costeo
- si aparecen componentes repetidos, se comportan como subensambles compartidos o piezas reutilizadas, no como un ciclo cerrado
- la diferencia de costeo observada no parece venir de una recursion infinita, sino de la forma en que SYSPRO consolida subensambles, redondeos y acumulacion de costos

Implicacion:

- el motor debe mantener proteccion contra ciclos
- pero para este caso de prueba la hipotesis principal no es recursividad, sino regla de acumulacion/cierre de costos en la BOM

## Criterio de actualizacion documental

Si aparecen nuevas tablas, campos o reglas:

1. Se actualiza primero `tablas_syspro_en_uso.md`.
2. Se ajusta `mapa_lectura_syspro.md`.
3. Se revisa este documento para mantener el flujo del modelo.

La idea es que `docs/` funcione como fuente viva del proyecto.

## Resumen operativo

El modelo de costeo quedo organizado en cuatro bloques:

1. Definir la conexion a SYSPRO.
2. Leer tablas reales de articulo, BOM, rutas, centros y `WhatIf`.
3. Calcular componentes y materiales.
4. Validar operaciones y overhead con datos reales de WIP.
