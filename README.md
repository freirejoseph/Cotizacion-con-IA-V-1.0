# Cotizador con IA V 1

## Version 1.0

Este repositorio contiene la primera version funcional del motor de costeo para cotizacion basado en la logica real de SYSPRO.

El objetivo de esta version es:

- leer un `ParentPart` o `StockCode` real desde SYSPRO
- reconstruir su costo usando maestro de inventario, BOM, operaciones y centros de trabajo
- reproducir el comportamiento del costeo `What-if`
- mostrar reportes planos y jerarquicos para validacion y analisis
- dejar una base estable para evolucionar hacia escenarios editables de cotizacion

## Alcance De La Version 1.0

La version `1.0` ya permite:

- conexion a SQL Server sobre la base `EncorePlasti1`
- lectura de `InvMaster`, `InvWarehouse`, `InvWhatIfCost`, `BomStructure`, `BomOperations` y `BomWorkCentre`
- calculo de cantidades efectivas con `EBQ`, `ScrapQuantity`, `ScrapPercentage` y cantidades fijas
- calculo de materiales, labor, overhead fijo y overhead variable
- acumulacion multinivel del costo en modo arbol
- generacion de reportes estilo SYSPRO
- ejecucion por formulario y por consola

Esta version no busca reemplazar SYSPRO.
Busca leer su estructura real, interpretar su logica de costeo y convertirla en una herramienta util para cotizacion y analisis.

## Estructura Principal

- `src/cotizador_ia/`
  - motor de costeo y configuracion
- `connectors/`
  - acceso a SQL Server
- `scripts/`
  - formulario, pruebas de conexion y generacion de reportes
- `docs/`
  - documentacion tecnica del modelo y tablas reales
- `skills/syspro-costing-engine/`
  - skill operativo para explicar, mantener y extender el motor
- `outputs/`
  - salidas de reportes generados

## Como Ejecutar

### Probar conexion

```powershell
python scripts/test_syspro_connection.py
```

### Generar reporte por consola

```powershell
python scripts/generate_bom_costing_report.py <PARENTPART_REAL> --batch-qty <LOTE>
```

### Generar reporte jerarquico

```powershell
python scripts/generate_bom_costing_report.py <PARENTPART_REAL> --batch-qty <LOTE> --tree
```

### Abrir formulario

```powershell
python scripts/bom_costing_form.py
```

O:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\run_bom_costing_form.ps1
```

## Caso De Regresion Documentado

Caso de validacion conocido para comparar comportamiento:

- `ParentPart: 9320000432`
- `Route: 0`
- `BatchQty: 12500`

Este caso sirve como referencia de regresion.
El motor no esta limitado a ese codigo y debe funcionar para cualquier `StockCode` o `ParentPart` valido en las tablas base.

## Documentacion Base

Punto de entrada tecnico:

- [Modelo de costeo SYSPRO](docs/modelo_costeo_syspro.md)
- [README tecnico de implementacion](docs/README_tecnico_implementacion_syspromodel.md)
- [Flujo de costeo What-if](docs/flujo_costeo_whatif_syspro.md)
- [Tablas SYSPRO en uso](docs/tablas_syspro_en_uso.md)
- [Mapa de lectura SYSPRO](docs/mapa_lectura_syspro.md)

Documentacion operativa del motor:

- [Skill de Motor de Costeo SYSPRO](skills/syspro-costing-engine/SKILL.md)

## Estado Tecnico De La 1.0

La base actual ya valida:

- lectura de item padre
- explosion de BOM
- costeo directo por `InvWhatIfCost`
- costeo de operaciones desde `BomOperations` y `BomWorkCentre`
- acumulacion ascendente desde hojas hasta el nodo padre
- proteccion contra ciclos en el arbol

La siguiente fase prevista es construir sobre esta base:

- escenarios editables de componentes
- escenarios editables de maquinas y centros de trabajo
- variacion de cantidades y scrap
- simulacion de costos y `EBQ`
- comparativos base vs escenario

## Regla De Trabajo

Antes de cambiar formulas, tablas o consultas:

1. revisar `docs/`
2. confirmar la regla en SYSPRO o en los scripts SQL documentados
3. ajustar el motor
4. validar con un `ParentPart` real
5. documentar el cambio

## Nota De Entorno

La conexion real se apoya en `.env` en la raiz del proyecto.
Ese archivo no debe publicarse con credenciales activas.
