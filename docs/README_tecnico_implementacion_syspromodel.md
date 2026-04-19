# README tecnico de implementacion - Skill de uso Costeo SYSPRO

Este documento funciona como guia de uso del proyecto de costeo y cotizacion sobre SYSPRO.

La idea es que sirva como referencia operativa para:

- entender el modelo de trabajo
- conocer los accesos
- saber que tablas usar
- ejecutar calculos iniciales
- mantener actualizada la documentacion viva en `docs/`

## 1. Proposito

Construir un cotizador que tome un articulo de SYSPRO y reconstruya su costo usando:

- maestro de articulo
- BOM
- rutas y operaciones
- centros de trabajo
- costos por warehouse
- validacion con WIP

Este proyecto no busca reemplazar SYSPRO. Busca leerlo, interpretar su modelo de costeo y devolver un costo util para analisis o cotizacion.

## 2. Fuentes oficiales del proyecto

Antes de trabajar en codigo, notebook o consultas, la fuente de verdad es `docs/`.

Documentos principales:

- `docs/modelo_costeo_syspro.md`
- `docs/mapa_lectura_syspro.md`
- `docs/tablas_syspro_en_uso.md`
- `docs/Script SQL/SYSPRO61.SQL`
- `docs/Script SQL/SYSPRO61SP1.SQL`
- `docs/Script SQL/EncorePlasti1 Script SQL.sql`
- `docs/Documentacion sobre Costeo.pdf`
- `docs/Tablas de SYSPRO ERP.pdf` como apoyo visual
- `docs/flujo_costeo_whatif_syspro.md`

Regla de trabajo:

1. primero se revisa `docs/`
2. luego se ajustan tablas, formulas o consultas
3. despues se implementa el cambio en notebooks o codigo

## 3. Accesos

### Conexion de trabajo

- Servidor: `192.168.1.5`
- Base de datos: `EncorePlasti1`
- Usuario tecnico: `sa5`
- Autenticacion: SQL Server

### Archivo de configuracion

- `.env` en la raiz del proyecto
- `configurations/database.local.yml` como respaldo documental

El archivo `.env` concentra la cadena de conexion real que usa el cotizador.

### Recomendaciones de seguridad

- no incrustar credenciales en notebooks de produccion
- no copiar la cadena de conexion dentro de logs o reportes
- mantener `.env` y `database.local.yml` fuera de cualquier publicacion externa

## 4. Modelo funcional

El modelo se divide en cuatro bloques:

1. conexion a SYSPRO
2. lectura de tablas reales
3. calculo de componentes
4. validacion de operaciones y overhead

### 4.1 Conexion

Objetivo:

- abrir SQL Server
- validar acceso a `EncorePlasti1`
- preparar un conector reutilizable

Salida esperada:

- conexion activa
- lectura de tablas base
- verificacion de esquema

### 4.2 Formulario de validacion

Entrada visual recomendada:

- `scripts/bom_costing_form.py`

Este formulario pide el `ParentPart`, permite elegir entre:

- `Relac. materiales`
- `Simulacion`

y muestra el reporte de validacion con el formato base de SYSPRO.

La pantalla de SYSPRO que usamos como referencia funcional incluye:

- `Cost based on`
- `Cost to update`
- `Itiner = 0 - ROUTE 0`
- filtro por numero de parte
- filtro por warehouse
- opciones de impresion y procesamiento

El cotizador replica esa logica para pruebas, aunque la salida de `B.O.M. cost` y la salida `What-if` se tratan como conceptos distintos.

### 4.3 Lectura de tablas

Tablas base actuales:

- `InvMaster`
- `InvWarehouse`
- `InvWhControl`
- `BomStructure`
- `BomOperations`
- `BomWorkCentre`
- `BomCostCentre`
- `WipMaster`
- `WipJobAllMat`
- `WipJobAllLab`

### 4.4 Calculo de componentes

Secuencia minima:

1. leer el articulo padre
2. leer la BOM
3. explotar componentes
4. aplicar scrap
5. aplicar cantidades fijas
6. leer `InvWhatIfCost`
7. multiplicar por costo simulado
8. acumular costo de materiales

Reglas confirmadas en validacion:

- usar 6 decimales en la cantidad efectiva
- `ScrapQuantity` se divide por `EBQ`
- `ScrapPercentage` se aplica sobre la cantidad ajustada
- si `WhatIfMatCost` es cero, el componente se deja en cero
- la linea del componente se imprime con la cantidad efectiva, no con la base

### 4.5 Operaciones y overhead

Secuencia minima:

1. leer operaciones de la ruta
2. resolver el work centre
3. tomar rates desde centro de trabajo o cost centre
4. calcular setup, run, startup y teardown
5. agregar subcontrato cuando exista
6. sumar overhead fijo y variable

### 4.6 What-if versus BOM base

SYSPRO muestra dos referencias distintas:

- `What-if Costing Report`
- `B.O.M. cost`

La primera salida es la simulacion que el cotizador debe reproducir.
La segunda es una referencia base/historica del BOM.
No deben mezclarse al comparar resultados.

## 5. Lineamientos de implementacion

### 5.1 Separacion por capas

- `configurations/`: parametros, conexion y entorno
- `connectors/`: acceso a SQL Server o futuros adaptadores
- `libraries/`: formulas reutilizables
- `notebooks/`: validacion y exploracion
- `sql/`: consultas y scripts de lectura
- `docs/`: definicion del modelo y decisiones del proyecto

En `notebooks/` se mantiene tambien un indice de ejecucion con los comandos para correr el formulario y el generador de reportes.

### 5.2 Criterios de lectura

- usar nombres reales de SQL cuando existan
- evitar inventar tablas o campos
- si hay duda, validar contra `docs/Script SQL/SYSPRO61.SQL` y `docs/Script SQL/SYSPRO61SP1.SQL`
- si una tabla cambia, actualizar primero `tablas_syspro_en_uso.md`

### 5.3 Criterios de calculo

- trabajar con EBQ cuando el modelo lo requiera
- respetar scrap y cantidades fijas
- separar costo de material de costo de operacion
- usar WIP solo como validacion, no como reemplazo del modelo
- usar `InvWhatIfCost` como dependencia de validacion para la simulacion `What-if` en la base actual
- mantener `Route 0` como itinerario de validacion
- no introducir recursividad en la linea visible del componente

## 6. Calculos base

### 6.1 Materiales

Formula base:

- `qty_neta = qty_por + scrap_quantity / EBQ + ajuste_por_scrap`
- `material_cost = qty_neta * whatif_mat_cost`

La primera salida de validacion del cotizador usa `InvWhatIfCost` como fuente de costo directo del componente en la base actual. Si `WhatIfMatCost` viene en cero, el componente se conserva en cero para respetar el comportamiento observado en SYSPRO.

Si existe cantidad fija:

- respetar `FixedQtyPerFlag`
- no asumir linealidad sin validar la estructura

### 6.2 Operaciones

Variables de trabajo:

- `EBQ`
- `PU`
- `setup_time`
- `run_time`
- `startup_time`
- `teardown_time`
- `fixed_rate`
- `variable_rate`

La primera version del motor debe producir:

- costo por operacion
- costo por ruta
- costo total de fabricacion

### 6.3 Validacion con WIP

Cruces recomendados:

- `WipMaster` contra el articulo y la cabecera del job
- `WipJobAllMat` contra componentes emitidos
- `WipJobAllLab` contra tiempos y mano de obra

El objetivo no es copiar WIP, sino verificar que el modelo calculado sea coherente con lo ejecutado.

## 7. Flujo detallado de `What-if`

El flujo que seguimos para validar la simulacion es:

1. Capturar el `ParentPart`.
2. Forzar `Route 0`.
3. Leer `InvMaster` del padre.
4. Leer `BomStructure` del padre.
5. Para cada componente, leer `InvWhatIfCost` por `StockCode` y `Warehouse`.
6. Calcular la cantidad efectiva con 6 decimales.
7. Aplicar `ScrapQuantity / EBQ` y luego `ScrapPercentage`.
8. Respetar `FixedQtyPerFlag` y `FixedQtyPer`.
9. Multiplicar por `WhatIfMatCost`.
10. Leer `BomOperations` y `BomWorkCentre`.
11. Calcular labor, fixed overhead y variable overhead.
12. Construir el reporte `What-if Costing Report`.
13. Comparar contra la captura de SYSPRO.
14. Si existe desviacion, bajar a la rama hija inmediata.

## 8. Flujo de uso recomendado

1. leer `docs/modelo_costeo_syspro.md`
2. revisar `docs/tablas_syspro_en_uso.md`
3. ejecutar `scripts/test_syspro_connection.py`
4. abrir `notebooks/01_validacion_syspromodel_costeo.ipynb`
5. validar conexion a `EncorePlasti1`
6. validar tablas y columnas reales
7. armar consultas de costeo
8. comparar resultados con un ejemplo real

## 9. Actualizacion del conocimiento

Cuando aparezca informacion nueva:

1. actualizar `docs/`
2. ajustar el notebook si cambia la lectura
3. documentar el cambio en el modelo

La idea es que `docs/` sea el manual vivo del proyecto.

## 10. Siguiente paso tecnico

La siguiente accion recomendada es ejecutar el notebook inicial para:

- confirmar conexion
- listar tablas
- leer columnas de `InvMaster`, `BomStructure`, `BomOperations`, `BomWorkCentre` y `WipMaster`
- preparar la primera consulta de costeo real
