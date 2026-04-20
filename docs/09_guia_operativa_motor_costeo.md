# Guia operativa del motor de costeo

## Objetivo

Esta guia concentra las reglas operativas para entender, mantener y extender el motor de costeo del proyecto.

Su funcion es reemplazar la documentacion equivalente que antes estaba distribuida en la carpeta `skills/`.

## Archivos principales del motor

- `src/cotizador_ia/bom_costing.py`
- `src/cotizador_ia/settings.py`
- `connectors/syspro_sqlserver.py`
- `scripts/bom_costing_form.py`
- `scripts/generate_bom_costing_report.py`
- `scripts/test_syspro_connection.py`

## Flujo base de trabajo

Para cualquier cambio, analisis o explicacion del motor, seguir este orden:

1. Leer el motor actual:
   - `src/cotizador_ia/bom_costing.py`
   - `src/cotizador_ia/settings.py`
   - `connectors/syspro_sqlserver.py`
   - `scripts/bom_costing_form.py`
   - `scripts/generate_bom_costing_report.py`
2. Confirmar si el cambio afecta:
   - lectura de datos maestros
   - logica de cantidades BOM
   - costeo de operaciones
   - expansion del arbol
   - formato de salida
   - comportamiento de simulacion
3. Mantener separadas estas capas:
   - datos fuente leidos desde SYSPRO
   - reglas del motor de calculo
   - salida de reporte o interfaz
4. Validar con un `ParentPart` real cuando sea posible.
5. Tratar cualquier `StockCode` o `ParentPart` como entrada valida del motor si existe en las tablas base requeridas.

## Flujo base del motor

Al explicar o modificar el motor, razonar en esta secuencia:

1. Cargar entorno y cadena de conexion desde `.env`.
2. Leer el item padre desde `InvMaster`.
3. Determinar el lote efectivo desde el valor recibido o desde `Ebq`.
4. Leer la BOM del padre desde `BomStructure`.
5. Calcular la cantidad efectiva de cada componente con reglas de scrap y cantidad fija.
6. Resolver el costo del componente desde `InvWhatIfCost` y luego aplicar fallback si el codigo lo requiere.
7. Leer las operaciones de fabricacion desde `BomOperations`.
8. Resolver tasas desde `BomWorkCentre` usando `WcRateInd`.
9. Convertir tiempos y capacidades en labor, overhead fijo, overhead variable y subcontrato.
10. Acumular el costo hacia arriba:
    - reporte plano: costo visible por componente directo
    - reporte arbol: total recursivo desde los hijos mas bajos hasta el padre
11. Formatear la salida final en un layout estilo SYSPRO.

## Reglas de cuidado

Aplicar siempre estas reglas:

1. Tratar `InvMaster`, `BomStructure`, `BomOperations`, `BomWorkCentre`, `InvWarehouse` e `InvWhatIfCost` como entradas criticas del negocio.
2. No mezclar el total de simulacion `What-if` con `B.O.M. cost` historico salvo que la tarea pida comparacion explicita.
3. Respetar el comportamiento de precision:
   - cantidades con 6 decimales donde el motor ya lo hace
   - importes redondeados con `_r5` a 5 decimales
4. Mantener la proteccion contra ciclos en el recorrido recursivo del arbol.
5. Distinguir entre:
   - costo visible del componente directo en reporte plano
   - costo totalmente acumulado del nodo hijo en reporte arbol
6. Si se agrega capacidad de escenarios editables, conservar intacta la lectura base desde SYSPRO y aplicar overrides por encima, no en reemplazo de la logica canonica.

## Validacion recomendada

Usar estas validaciones despues de cambios materiales:

1. `python scripts/test_syspro_connection.py`
2. `python scripts/generate_bom_costing_report.py <PARENTPART_REAL> --batch-qty <LOTE> --tree`
3. `python scripts/generate_bom_costing_report.py <PARENTPART_REAL> --batch-qty <LOTE>`
4. `python scripts/bom_costing_form.py`

Caso de regresion sugerido:

- `ParentPart 9320000432`
- `Route 0`
- `BatchQty 12500`

## Guia visual paso a paso para Estimaciones

Usar `9320000432` como caso base funcional para validar la interfaz `Estimaciones`.

Objetivo de esta guia:

- revisar layout
- validar distribucion de paneles
- confirmar visibilidad de campos editables
- confirmar consistencia numerica con el reporte textual `What-if`
- documentar un mismo caso de referencia para todas las iteraciones

Secuencia recomendada:

1. Abrir la maqueta:
   - `python scripts/bom_costing_form.py`
2. Confirmar que la pantalla arranca con:
   - `ParentPart = 9320000432`
   - `Ruta = 0 - ROUTE 0`
   - `Lote` inicial tomado desde `InvMaster.Ebq` si aun no hay override
   - `EBQ` visible desde maestro
3. Revisar la cabecera superior:
   - validar que el padre visible sea `9320000432`
   - validar descripcion de referencia
   - validar que `Lote estimación` sea editable
   - validar que `EBQ` y `Warehouse` queden visibles como solo lectura
4. Revisar el panel izquierdo:
   - confirmar que el arbol use `9320000432` como nodo raiz
   - confirmar que se distingan componentes, subensambles y operaciones
   - si `Maintain hierarchies` esta desmarcado, el detalle visible debe quedar a 1 nivel
   - si `Maintain hierarchies` esta marcado, solo debe expandirse el detalle, no cambiar el total
5. Revisar el panel derecho superior:
   - confirmar que las operaciones se vean en formato tabular
   - confirmar columnas operativas principales:
     - `Work center`
     - `Description`
     - `Rate ind`
     - `Run time`
     - `Ciclo`
     - `Setup time`
     - `Startup time`
     - `Teardown time`
     - `Sub-contracted`
   - validar que `Agregar`, `Editar` y `Eliminar` esten disponibles
6. Revisar el panel derecho inferior:
   - confirmar que los componentes del caso `9320000432` sean legibles
   - validar que `Agregar`, `Editar` y `Eliminar` esten disponibles
   - validar que al poner `N° parte` y pulsar `Enter` se cargue la descripcion desde `InvMaster`
7. Revisar el resumen de costo:
   - validar jerarquia visual de `Material`, `Labor`, `OH fijo`, `OH variable` y `Total simulado`
   - este bloque debe quedar siempre visible como salida principal del escenario
8. Validar recosteo en vivo:
   - cambiar `Lote estimación`
   - editar `Cantidad unitaria` o `Costo unitario` de un componente
   - editar `Work center` o tiempos de una operacion
   - confirmar que el resumen se actualice
9. Validar consistencia con reporte textual:
   - lanzar `Jerarquía`
   - comparar con `python scripts/generate_bom_costing_report.py 9320000432 --batch-qty <LOTE>`
   - confirmar mismo total en formulario y reporte

Regla de trabajo para esta fase:

- usar `9320000432` como referencia funcional y visual estable
- el costo mostrado en formulario debe coincidir con el reporte textual
- `Maintain hierarchies` solo cambia la visualizacion del detalle, no el costo base
- la estructura editable debe vivir en memoria, sin alterar SYSPRO

Si los resultados no coinciden con lo esperado, revisar en este orden:

1. cadena de conexion y contexto de warehouse
2. registro padre en `InvMaster`
3. formula de cantidades del componente
4. busqueda de costo what-if
5. seleccion de tasas operativas
6. recursion o repeticion de hijos
7. formato final del reporte

## Resumen tecnico del motor

El motor actual vive principalmente en:

- `src/cotizador_ia/bom_costing.py`
- `connectors/syspro_sqlserver.py`
- `src/cotizador_ia/settings.py`
- `scripts/generate_bom_costing_report.py`
- `scripts/bom_costing_form.py`

Tablas principales usadas por el motor:

- `InvMaster`
- `InvWarehouse`
- `InvWhatIfCost`
- `BomStructure`
- `BomOperations`
- `BomWorkCentre`

Reglas base del calculo:

1. Leer el item padre desde `InvMaster`.
2. Resolver `EBQ` efectivo desde el lote recibido o desde `InvMaster.Ebq`.
3. Leer componentes desde `BomStructure`.
4. Calcular cantidad efectiva por componente:
   - usar `QtyPer` o `QtyPerEnt`
   - si `FixedQtyPerFlag = Y`, usar `FixedQtyPer` o `FixedQtyPerEnt`
   - si no, sumar `ScrapQuantity / EBQ`
   - luego aplicar `ScrapPercentage`
5. Resolver costo del componente desde `InvWhatIfCost` cuando exista.
6. Aplicar fallback con `InvMaster` e `InvWarehouse` cuando corresponda.
7. Leer operaciones desde `BomOperations`.
8. Resolver tasas desde `BomWorkCentre` segun `WcRateInd`.
9. Calcular labor, overhead fijo, overhead variable y subcontrato.
10. Acumular el costo al padre.

Alcance funcional del motor:

- debe funcionar para cualquier `StockCode` o `ParentPart`
- no debe depender de codigos documentados de ejemplo
- los codigos mencionados en la documentacion sirven solo como validacion, regresion o referencia de pruebas

## Logica multinivel

Flujo conceptual del reporte arbol:

```text
ParentPart
  -> hijo directo
     -> nieto
        -> hoja
```

La subida del costo funciona asi:

```text
TotalNodoPadre =
    SUM(CantidadRequeridaHijo * TotalNodoHijo)
  + CostoOperacionesDelPadre
```

Caso base:

- si un item no tiene BOM ni operaciones, se trata como hoja
- su costo sale de `InvWhatIfCost` o del fallback disponible

Caso recursivo:

- si un item tiene hijos, cada hijo se costea primero
- el total del hijo se multiplica por la cantidad requerida en el padre
- luego se suman las operaciones propias del padre

## Extension recomendada para escenarios

Para futuras versiones:

- mantener una capa canonica que lea SYSPRO sin alterar datos
- agregar una capa de overrides en memoria para:
  - maquinas
  - componentes
  - cantidades
  - scrap
  - costos
  - overrides multinivel por nodo

## Estado implementado al 2026-04-19

La pantalla `Estimaciones` ya implementa:

- carga inicial rapida con `calculate_stock_cost()`
- `Estimar` con barra de avance
- `Jerarquía` en ventana textual
- igualdad de costo entre formulario y reporte `What-if`
- detalle jerarquico opcional sin alterar el total
- edicion de escenario en memoria sobre:
  - lote de estimacion
  - componentes
  - operaciones
- botones funcionales:
  - `Agregar`
  - `Editar`
  - `Eliminar`
- carga asistida desde maestro:
  - descripcion de `Work center` desde `BomWorkCentre`
  - descripcion de `N° parte` desde `InvMaster`

## Criterio documental

La documentacion operativa del motor debe mantenerse en `docs/`.

No se debe volver a duplicar esta misma informacion en otra carpeta documental del repositorio.
