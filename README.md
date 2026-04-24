# Cotizador con IA V 1

Este repositorio contiene el motor de costeo del proyecto, orientado a reconstruir costos reales de SYSPRO y servir como base para cotizacion, validacion y futuros escenarios editables.

## Que hace

- lee un `ParentPart` o `StockCode` real desde SYSPRO
- reconstruye costos de materiales y operaciones
- reproduce la logica observada del reporte `What-if`
- genera reportes planos y jerarquicos para validacion
- incluye una primera estacion operativa `Estimaciones` con interfaz tipo SYSPRO
- soporta escenarios editables en memoria para componentes y operaciones
- soporta reglas masivas de simulacion por `ProductClass`
- incluye ayuda integrada y salida imprimible del reporte jerarquico
- muestra la informacion de cada nodo de `Jerarquia` en una sola fila, con encabezados resaltados
- permite empaquetar la herramienta como ejecutable Windows

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

Compilar ejecutable:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\build_estimaciones_exe.ps1
```

Opcion de un clic:

- [Compilar Ejecutable.bat](Compilar%20Ejecutable.bat)

## Casos de validacion conocidos

- `ParentPart: 9320000432`
- `Route: 0`
- `BatchQty: 12500`
- `BatchQty: 25000`
- validar que formulario y reporte textual coincidan con y sin `Maintain hierarchies`

## Documentacion

La documentacion detallada vive en `docs/`.

Punto de entrada recomendado:

- [Indice de documentacion](docs/README.md)
- [01. Onboarding](docs/01_onboarding_nuevo_desarrollo_motor_costeo.md)
- [02. Conocimiento consolidado](docs/02_conocimiento_motor_costeo.md)
- [03. Matriz de trazabilidad](docs/03_matriz_trazabilidad_motor_costeo.md)
- [09. Guia operativa del motor](docs/09_guia_operativa_motor_costeo.md)
- [10. Estimaciones v1.1](docs/10_estimaciones_v1_1_definicion_funcional.md)
- [12. Empaquetado a EXE](docs/12_empaquetado_estimaciones_exe.md)
- [13. Transportabilidad a nueva maquina](docs/13_transportabilidad_nueva_maquina_vscode.md)
- [14. Factor Mass universal y propagacion de lotes](docs/14_factor_mass_universal_y_propagacion_de_lotes.md)

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

## Estado actual de Estimaciones

La version actual de `scripts/bom_costing_form.py` ya no es una maqueta vacia.

Incluye:

- carga rapida inicial con logica `What-if`
- vista jerarquica como detalle visual, sin alterar el total base
- paneles de `Parent Information`, `Operaciones`, `Componentes` y resumen de costos
- recosteo automatico al editar campos criticos del escenario
- acciones `Agregar`, `Editar` y `Eliminar` sobre componentes y operaciones
- accion `Actualizar` para aplicar cambios masivos por `ProductClass`
- ayuda integrada con `F1`
- impresion del reporte textual desde `Jerarquia`
- reporte `Jerarquia` alineado por nodo: codigo, descripcion, W/H, ruta, UDM, Mass, lote, kilos y EBQ quedan en la misma fila
- formularios auxiliares que cargan descripcion desde maestro al ingresar:
  - `Work center` desde `BomWorkCentre`
  - `ProductClass` desde `SalProductClass`
  - `N° parte` desde `InvMaster`

Ademas:

- el ejecutable puede resolver `.env` desde la carpeta del EXE, `configurations/`, el directorio actual o la raiz del proyecto
- `scripts/build_estimaciones_exe.ps1` refresca automaticamente `Ejecutable/` para facilitar la entrega a usuarios finales

La entrega operativa para usuarios finales se prepara en la carpeta `Ejecutable/`.
