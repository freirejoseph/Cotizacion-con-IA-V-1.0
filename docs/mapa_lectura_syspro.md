# Mapa de lectura SYSPRO para costeo

Este documento define la informacion que el cotizador debe leer desde SYSPRO para poder reconstruir el costo de un articulo padre.

La lista funcional se mantiene alineada con:

- `Documentacion sobre Costeo.pdf`
- `docs/Script SQL/SYSPRO61.SQL`
- `docs/Script SQL/SYSPRO61SP1.SQL`
- `docs/Script SQL/EncorePlasti1 Script SQL.sql`
- `Tablas de SYSPRO ERP.pdf` como apoyo visual
- `modelo_costeo_syspro.md`

La lectura se enfoca en dos salidas:

- `What-if Costing Report`
- `B.O.M. cost`

Importante:

- Los nombres exactos de tablas pueden variar segun la version y la implementacion de SYSPRO.
- Aqui se documenta primero el mapa funcional de lectura.
- Luego, cuando conectemos la base real o revisemos los scripts instaladores, se completaran los nombres fisicos exactos de tablas y campos.

## 1. Maestro de articulos

### Proposito

Identificar el articulo padre y sus atributos base de costeo.

### Campos necesarios

- Codigo de articulo
- Descripcion corta
- Descripcion larga
- Tipo de stock
- Unidad de medida de inventario
- Unidad de manufactura, si aplica
- EBQ o economic batch quantity
- Warehouse por defecto
- Categoria del articulo
- Estado ECC / revision / release
- Indicador de notional part
- Indicador de co-producto

### Uso en el calculo

- Define el articulo a costear.
- Sirve como punto de partida para buscar BOM, ruta y operaciones.
- Aporta la unidad base sobre la cual se distribuyen los costos.

## 2. Estructura BOM

### Proposito

Leer la relacion padre - componente y la cantidad requerida por nivel.

### Campos necesarios

- Codigo del padre
- Codigo del componente
- Cantidad por
- Unidad de medida del componente
- Scrap %
- Cantidad fija, si aplica
- Secuencia
- Nivel
- Warehouse del componente
- Fecha de vigencia desde
- Fecha de vigencia hasta
- Estado de la estructura
- Indicador de co-producto o notional

### Uso en el calculo

- Calcula el consumo de materiales.
- Permite explotar la estructura por niveles.
- Alimenta el costeo acumulado de subensambles.

## 3. Ruta de fabricacion

### Proposito

Leer la secuencia de operaciones necesarias para fabricar el articulo.

### Campos necesarios

- Codigo del padre
- Codigo de ruta
- Numero de operacion
- Secuencia
- Work center
- Tipo de operacion
- Tiempo de corrida
- Tiempo de setup
- Tiempo de startup
- Tiempo de teardown
- Rate de corrida
- Rate de setup
- Rate de startup
- Rate de teardown
- Cantidad productiva
- Operacion subcontratada
- Tiempo de traslado, si existe
- Rendimiento, si existe

### Uso en el calculo

- Permite calcular mano de obra y carga de fabrica.
- Sirve para distribuir setup, run, startup y teardown.
- Es necesario para overhead fijo y variable.

## 4. Centros de trabajo

### Proposito

Obtener los costos base asociados a la ejecucion de una operacion.

### Campos necesarios

- Codigo de work center
- Descripcion
- Tasa de costo
- Tipo de centro
- Capacidad
- Calendarizacion
- Moneda
- Costos reales, si se van a comparar

### Uso en el calculo

- Fuente de tasas y parametros de operacion.
- Ayuda a validar la logica contra costos reales.

## 5. Warehouses

### Proposito

Resolver de donde se toman los costos de inventario y componentes.

### Campos necesarios

- Codigo de warehouse
- Descripcion
- Costeo por warehouse
- Warehouse por defecto del articulo
- Configuracion de aplicacion de BOM por warehouse

### Uso en el calculo

- Determina el costo a usar cuando SYSPRO maneja costeo por almacen.
- Controla el origen del costo de materiales.

## 6. What-if / Simulacion

### Proposito

Leer la fuente real del costo simulado que SYSPRO usa en `What-if Costing Report`.

Nota:

- solo las tablas y relaciones reales del instalador se consideran fuente oficial
- cualquier objeto derivado del proyecto queda fuera de este mapa canonico

### Tabla de validacion para simulacion

- `InvWhatIfCost`

### Campos necesarios

De `InvWhatIfCost`:

- `StockCode`
- `Warehouse`
- `WhatIfMatCost`
- `WhatIfLabCost`
- `WhatIfFixCost`
- `WhatIfVarCost`
- `WhatIfSubContCost`

De `BomStructure`:

- `QtyPer`
- `QtyPerEnt`
- `ScrapPercentage`
- `ScrapQuantity`
- `FixedQtyPerFlag`
- `FixedQtyPer`
- `ScrapQuantityEnt`
- `FixedQtyPerEnt`

### Uso en el calculo

- Define el costo visible del componente en el reporte `What-if`.
- Permite validar si un articulo debe quedar en cero.
- Sostiene la cantidad efectiva con 6 decimales.
- Ajusta el consumo por scrap y por cantidad fija.
- En la base actual de validacion se usa para reproducir `What-if`; queda pendiente reconciliar formalmente su origen con el instalador original.

## 7. Configuracion de BOM y WIP

### Proposito

Leer las reglas que cambian la logica de costeo.

### Campos necesarios

- Costeo por warehouse
- Alternate routings required
- ABC costing required
- Structure on / off dates required
- ECC control level
- Use manufacturing UoM
- Include non-current components by default
- Warn about cost implosion not completed
- Co-product settings

### Uso en el calculo

- Ajusta la forma en que se leen las estructuras.
- Determina si se muestran componentes no vigentes.
- Controla el comportamiento de costo por revision y por almacen.

## 8. Co-productos y partes nocionales

### Proposito

Distribuir o repartir costo entre productos relacionados.

### Campos necesarios

- Codigo del padre nocional
- Codigo del co-producto
- Porcentaje de costo
- Tipo de co-producto
- Imputacion de costo
- Unidad de referencia

### Uso en el calculo

- Reparte el costo del padre entre productos relacionados.
- Cambia la regla de acumulacion cuando el articulo no es un padre normal.

## 9. Costeo resultado / consulta

### Proposito

Comparar el costo calculado con el costo que SYSPRO ya tiene almacenado o calculado.

### Campos necesarios

- Costo material
- Costo de trabajo
- Overhead fijo
- Overhead variable
- Costo subcontractado
- Costo total
- Costo actual vs costo calculado

### Uso en el calculo

- Sirve como referencia para validar la formula.
- Permite detectar diferencias entre la logica del programa y SYSPRO.

## Priorizacion de lectura

Orden recomendado de lectura desde la base SYSPRO:

1. Maestro de articulos.
2. Configuracion general de BOM y WIP.
3. Estructura BOM del articulo padre.
4. Ruta de fabricacion.
5. Centros de trabajo.
6. What-if / simulacion.
7. Warehouses.
8. Co-productos y partes nocionales.
9. Costo resultante para validacion.

## Salida esperada del lector

El primer modulo de lectura debe devolver una estructura como esta:

- `item_master`
- `bom_header`
- `bom_components`
- `routing_header`
- `routing_operations`
- `work_centers`
- `what_if_cost`
- `warehouses`
- `system_settings`
- `co_products`
- `calculated_vs_actual_cost`
