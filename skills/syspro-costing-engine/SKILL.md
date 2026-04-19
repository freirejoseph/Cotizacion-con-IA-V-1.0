---
name: syspro-costing-engine
description: Documentar, explicar, mantener y extender el motor de costeo de productos basado en SYSPRO usado en este repositorio. Usar este skill cuando Codex necesite trabajar sobre la logica de BOM, operaciones, centros de trabajo, manejo de EBQ, reglas de scrap, costos what-if, acumulacion multinivel, generacion de reportes de costeo o preparacion de escenarios de cotizacion.
---

# Skill de Motor de Costeo SYSPRO

## Objetivo

Usar este skill para trabajar con seguridad sobre el motor de costeo implementado en `src/cotizador_ia/bom_costing.py`, el conector SQL en `connectors/syspro_sqlserver.py` y los puntos de ejecucion ubicados en `scripts/`.

## Inicio Rapido

Para cualquier cambio, analisis o explicacion, seguir este orden:

1. Leer los archivos actuales del motor:
   - `src/cotizador_ia/bom_costing.py`
   - `src/cotizador_ia/settings.py`
   - `connectors/syspro_sqlserver.py`
   - `scripts/bom_costing_form.py`
   - `scripts/generate_bom_costing_report.py`
2. Confirmar si el cambio solicitado afecta:
   - lectura de datos maestros
   - logica de cantidades BOM
   - costeo de operaciones
   - expansion del arbol
   - formato final del reporte
   - comportamiento de simulacion
3. Mantener separadas estas capas:
   - datos fuente leidos desde SYSPRO
   - reglas del motor de calculo
   - salida de reporte o interfaz
4. Validar con un `ParentPart` real cuando sea posible.
5. Tratar cualquier `StockCode` o `ParentPart` como entrada valida del motor si existe en las tablas base requeridas.

## Flujo Base De Trabajo

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

## Reglas De Cuidado

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

## Validacion Recomendada

Usar estas validaciones despues de cambios materiales:

1. `python scripts/test_syspro_connection.py`
2. `python scripts/generate_bom_costing_report.py <PARENTPART_REAL> --batch-qty <LOTE> --tree`
3. `python scripts/generate_bom_costing_report.py <PARENTPART_REAL> --batch-qty <LOTE>`
4. `python scripts/bom_costing_form.py`

Caso de regresion sugerido cuando se quiera comparar contra una prueba ya conocida:

- `ParentPart 9320000432`
- `Route 0`
- `BatchQty 12500`

Si los resultados no coinciden con lo esperado, revisar en este orden:

1. cadena de conexion y contexto de warehouse
2. registro padre en `InvMaster`
3. formula de cantidades del componente
4. busqueda de costo what-if
5. seleccion de tasas operativas
6. recursion o repeticion de hijos
7. formato final del reporte

## Resumen Tecnico Del Motor

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
- los codigos mencionados en este skill sirven solo como validacion, regresion o referencia de pruebas

Flujo multinivel del reporte arbol:

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

Extension recomendada para escenarios futuros:

- mantener una capa canonica que lea SYSPRO sin alterar datos
- agregar una capa de overrides en memoria para:
  - maquinas
  - componentes
  - cantidades
  - scrap
  - costos
  - `EBQ`

Caso de validacion principal documentado:

- `ParentPart 9320000432`
- `Route 0`
- `BatchQty 12500`
