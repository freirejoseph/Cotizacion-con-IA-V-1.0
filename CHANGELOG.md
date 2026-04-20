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
- documento de acuerdos operativos para registrar decisiones de colaboracion y flujo Git/GitHub

Objetivo de esta version:

- facilitar transferencia de conocimiento
- reducir ambiguedad para nuevos desarrollos
- mantener una estructura de repo mas limpia y legible

## 1.0.2 - 2026-04-19

Ajuste de la maqueta visual de `Estimaciones` para usar un caso de referencia estable.

Incluye:

- `scripts/bom_costing_form.py` actualizado para arrancar visualmente con `ParentPart 9320000432`
- datos demo de arbol, operaciones y componentes alineados al caso visual de referencia
- guia operativa paso a paso en `docs/09_guia_operativa_motor_costeo.md` para revisar la interfaz usando `9320000432`

Objetivo de esta version:

- fijar un caso visual comun para iteraciones de diseno
- facilitar revisiones de layout sobre una misma referencia
- dejar trazabilidad documental antes de conectar el llenado real

## 1.0.3 - 2026-04-19

Rediseño visual de la maqueta `Estimaciones` para acercarla al look and feel de SYSPRO.

Incluye:

- barra de menú superior con acciones tipo ERP
- cabecera azul con `ParentPart`, `Ruta` y acciones visibles en una sola línea
- paneles visuales más cercanos a SYSPRO para información del padre, árbol, operaciones y componentes
- tablas más densas y compactas para simular una pantalla interna del ERP
- barra de estado inferior con mensaje operativo persistente
- visualización de `Mass` desde `InvMaster` para preparar la futura conversión a kilos
- botón `Jerarquía` conectado para mostrar el árbol textual en pantalla
- recalculo del resumen al usar `Estimar` y también al cambiar campos clave del escenario
- carga inicial en segundo plano para evitar que la ventana tarde en aparecer
- bloque `Estimate Parent Details` con cifras grandes y centradas
- ajuste del panel `Estimación` para reducir espacios en blanco sin uso
- campo `Mass` visible solo con valor real cuando exista en `InvMaster`
- mensaje de estado simplificado al formato operativo de carga y actualización
- panel `Estimación` dividido en árbol principal y detalle inferior del nodo seleccionado

Objetivo de esta version:

- hacer que la maqueta se sienta como un módulo interno de ERP
- reducir la distancia visual respecto a la referencia de SYSPRO
- dejar una base más creíble antes de conectar lectura real y edición funcional

## 1.0.4 - 2026-04-19

Consolidacion funcional y documental de `Estimaciones`.

Incluye:

- consistencia entre formulario y reporte textual `What-if`
- `Maintain hierarchies` limitado a detalle visual, sin cambiar el costo oficial
- escenario editable en memoria para componentes y operaciones
- acciones funcionales `Agregar`, `Editar` y `Eliminar`
- carga de descripcion de `Work center` desde `BomWorkCentre`
- carga de descripcion de `N° parte` desde `InvMaster`
- columna `Ciclo` en operaciones como unidades por hora derivadas de `Run time`
- empaquetado a ejecutable con:
  - `scripts/build_estimaciones_exe.ps1`
  - `Compilar Ejecutable.bat`
  - `docs/12_empaquetado_estimaciones_exe.md`
- actualizacion de `README.md`, `docs/README.md`, `docs/09_guia_operativa_motor_costeo.md` y `docs/10_estimaciones_v1_1_definicion_funcional.md`

Objetivo de esta version:

- dejar una primera entrega util para pruebas con usuarios
- alinear documentacion con el estado real implementado
- establecer un flujo reproducible de compilacion y entrega

## 1.0.5 - 2026-04-20

Ampliacion operativa de `Estimaciones` y refuerzo del flujo de entrega local.

Incluye:

- ventana de ayuda integrada en `scripts/bom_costing_form.py` con acceso por menu y `F1`
- accion `Actualizar` para aplicar reglas masivas por `ProductClass`
- lectura de descripcion de `ProductClass` desde `SalProductClass`
- recalculo del arbol visible considerando reglas masivas del escenario
- boton `Imprimir` en la ventana `Jerarquia`
- arranque mas silencioso del fallback SQL en Windows para evitar ventanas de PowerShell
- busqueda de `.env` mas flexible para ejecucion normal y empaquetada
- actualizacion de `scripts/build_estimaciones_exe.ps1` para refrescar `Ejecutable/` y copiar `.env`
- actualizacion de `README.md` y documentos operativos de `docs/`

Objetivo de esta version:

- acercar `Estimaciones` a un uso operativo mas completo
- dejar documentadas las nuevas capacidades de simulacion
- facilitar la entrega del ejecutable en otra maquina sin reconfiguracion manual innecesaria
