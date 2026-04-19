# Cotizador con IA V 1

Este repositorio contiene el motor de costeo del proyecto, orientado a reconstruir costos reales de SYSPRO y servir como base para cotizacion, validacion y futuros escenarios editables.

## Que hace

- lee un `ParentPart` o `StockCode` real desde SYSPRO
- reconstruye costos de materiales y operaciones
- reproduce la logica observada del reporte `What-if`
- genera reportes planos y jerarquicos para validacion
- deja la base lista para evolucionar hacia `Estimaciones`

## Estructura activa del repositorio

- `src/cotizador_ia/`: motor de costeo y configuracion
- `connectors/`: acceso a SQL Server
- `scripts/`: formulario, pruebas de conexion y generacion de reportes
- `docs/`: documentacion funcional, tecnica y de transferencia de conocimiento
- `notebooks/`: exploracion y validacion puntual
- `outputs/`: reportes generados y salidas operativas
- `tests/`: espacio reservado para pruebas automatizadas

## Como ejecutar

Probar conexion:

```powershell
python scripts/test_syspro_connection.py
```

Generar reporte plano:

```powershell
python scripts/generate_bom_costing_report.py <PARENTPART_REAL> --batch-qty <LOTE>
```

Generar reporte arbol:

```powershell
python scripts/generate_bom_costing_report.py <PARENTPART_REAL> --batch-qty <LOTE> --tree
```

Abrir formulario:

```powershell
python scripts/bom_costing_form.py
```

Alternativa en PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\run_bom_costing_form.ps1
```

## Caso de regresion conocido

- `ParentPart: 9320000432`
- `Route: 0`
- `BatchQty: 12500`

## Documentacion

La documentacion detallada vive en `docs/`.

Punto de entrada recomendado:

- [Indice de documentacion](docs/README.md)
- [01. Onboarding](docs/01_onboarding_nuevo_desarrollo_motor_costeo.md)
- [02. Conocimiento consolidado](docs/02_conocimiento_motor_costeo.md)
- [03. Matriz de trazabilidad](docs/03_matriz_trazabilidad_motor_costeo.md)
- [09. Guia operativa del motor](docs/09_guia_operativa_motor_costeo.md)
- [10. Estimaciones v1.1](docs/10_estimaciones_v1_1_definicion_funcional.md)

## Regla de trabajo

Antes de cambiar formulas, tablas o consultas:

1. revisar `docs/`
2. confirmar la regla en SYSPRO o en los scripts SQL documentados
3. ajustar el motor
4. validar con un `ParentPart` real
5. documentar el cambio

## Nota de entorno

La conexion real se apoya en `.env` en la raiz del proyecto.

Ese archivo no debe publicarse con credenciales activas.
