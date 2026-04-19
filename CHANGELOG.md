# Changelog

## 1.0.0 - 2026-04-18

Primera version documental y funcional del proyecto.

Incluye:

- inicializacion del repositorio Git
- nodo raiz de documentacion en `README.md`
- documentacion tecnica base en `docs/`
- skill operativo del motor en `skills/syspro-costing-engine/SKILL.md`
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
