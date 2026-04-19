# Changelog

## 1.0.0 - 2026-04-18

Primera version documental y funcional del proyecto.

Incluye:

- inicializacion del repositorio Git
- `README.md` de raiz como portada operativa del repositorio
- `docs/README.md` como indice de documentacion
- documentacion tecnica base en `docs/`
- motor de costeo con lectura de:
  - `InvMaster`
  - `InvWarehouse`
  - `InvWhatIfCost`
  - `BomStructure`
  - `BomOperations`
  - `BomWorkCentre`
- soporte para:
  - reporte plano
  - reporte arbol
  - formulario de ejecucion
  - validacion de conexion

Caso de regresion documentado:

- `ParentPart 9320000432`
- `Route 0`
- `BatchQty 12500`

Objetivo de esta version:

- dejar una base estable para costeo y cotizacion
- documentar la logica real tomada de SYSPRO
- preparar el proyecto para evolucionar hacia escenarios editables y comparativos

## 1.0.1 - 2026-04-19

Reorganizacion documental y limpieza estructural del repositorio.

Incluye:

- secuencia numerica en los documentos principales de `docs/`
- ruta guiada de lectura en `docs/README.md`
- documento consolidado de conocimiento del motor
- matriz de trazabilidad `regla -> tabla -> codigo -> salida`
- guia de onboarding para nuevos desarrolladores
- limpieza de carpetas vacias no usadas en el desarrollo actual
- actualizacion de enlaces internos tras el reordenamiento documental

Objetivo de esta version:

- facilitar transferencia de conocimiento
- reducir ambiguedad para nuevos desarrollos
- mantener una estructura de repo mas limpia y legible
