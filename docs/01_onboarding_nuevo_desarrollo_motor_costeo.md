# Onboarding para continuar desarrollos del motor de costeo

## Objetivo

Esta guia esta pensada para un programador nuevo que entra al proyecto y necesita continuar desarrollos sin empezar desde cero.

La meta es que en una lectura corta pueda entender:

- que hace el sistema
- donde esta cada parte
- que debe leer primero
- como hacer cambios sin romper el motor
- que validaciones correr antes de dar algo por bueno

## Que es este proyecto

Este proyecto reconstruye el costo de un articulo padre de SYSPRO usando:

- maestro del articulo
- BOM
- operaciones de ruta
- centros de trabajo
- costos por warehouse
- validacion con datos WIP cuando hace falta

La referencia principal de negocio es la salida `What-if Costing Report` de SYSPRO.

## Cual es la idea central

Hay una regla arquitectonica que no conviene romper:

- SYSPRO es la fuente canonica
- el motor lee esa base canonica
- la logica de costeo vive en el motor
- la interfaz solo captura entradas, dispara calculo y muestra salidas

Si el proyecto evoluciona a escenarios editables, esos cambios deben vivir como `overrides` sobre la lectura base, no como una reescritura de la fuente canonica.

## Que leer primero

Orden de lectura recomendado:

1. `docs/README.md`
2. `docs/02_conocimiento_motor_costeo.md`
3. `docs/03_matriz_trazabilidad_motor_costeo.md`
4. `docs/09_guia_operativa_motor_costeo.md`
5. `docs/05_modelo_costeo_syspro.md`
6. `docs/06_mapa_lectura_syspro.md`
7. `docs/10_estimaciones_v1_1_definicion_funcional.md`

Despues de eso, pasar al codigo:

1. `src/cotizador_ia/bom_costing.py`
2. `connectors/syspro_sqlserver.py`
3. `scripts/generate_bom_costing_report.py`
4. `scripts/bom_costing_form.py`

## Donde vive cada responsabilidad

### Documentacion

- `docs/`: fuente viva del conocimiento funcional y tecnico

### Motor

- `src/cotizador_ia/bom_costing.py`: formulas, estructuras de salida, calculo plano y arbol

### Conexion a datos

- `connectors/syspro_sqlserver.py`: acceso a SQL Server

### Ejecucion operativa

- `scripts/generate_bom_costing_report.py`: genera reportes de validacion
- `scripts/bom_costing_form.py`: formulario de prueba y validacion visual

## Flujo mental para entender el motor

Pensar el motor en esta secuencia:

1. identificar el `ParentPart`
2. cargar contexto del padre desde `InvMaster`
3. resolver lote efectivo o `EBQ`
4. leer componentes desde `BomStructure`
5. calcular cantidades efectivas con scrap y cantidad fija
6. resolver costo `What-if` del componente
7. leer operaciones desde `BomOperations`
8. resolver tasas desde `BomWorkCentre`
9. calcular labor, overhead y subcontrato
10. acumular costo hacia arriba
11. devolver reporte plano o arbol

## Reglas que debes memorizar

Si solo recuerdas unas pocas reglas al empezar, que sean estas:

1. `What-if` y `B.O.M. cost` no son lo mismo.
2. La linea visible del componente en `What-if` usa costo directo del componente.
3. El total del arbol si acumula hijos y operaciones.
4. `ScrapQuantity` se divide por `EBQ`.
5. `ScrapPercentage` se aplica despues.
6. La cantidad visible usa 6 decimales.
7. Hay proteccion contra ciclos.
8. Cualquier nueva UI debe reutilizar el motor, no clonarlo.

## Como hacer un cambio sin perder trazabilidad

Usar este orden:

1. identificar la regla de negocio afectada
2. buscarla en `docs/03_matriz_trazabilidad_motor_costeo.md`
3. confirmar tablas y campos implicados
4. revisar el codigo afectado
5. actualizar primero `docs/`
6. aplicar cambio en codigo
7. validar con un caso real

## Cambios seguros y cambios sensibles

Cambios relativamente seguros:

- formato de salida
- nuevos reportes
- reorganizacion de capas de presentacion
- nuevas guias documentales

Cambios sensibles:

- formulas de cantidad efectiva
- fallback de costos
- acumulacion multinivel
- seleccion de tasas por `WcRateInd`
- logica de `EBQ`
- cualquier cambio en consulta SQL base

Si el cambio toca una zona sensible, documentarlo antes y validar despues contra un caso real.

## Casos de validacion recomendados

Caso de regresion sugerido:

- `ParentPart`: `9320000432`
- `Route`: `0`
- `BatchQty`: `12500`

Comandos utiles:

```powershell
python scripts/test_syspro_connection.py
python scripts/generate_bom_costing_report.py 9320000432 --batch-qty 12500
python scripts/generate_bom_costing_report.py 9320000432 --batch-qty 12500 --tree
python scripts/bom_costing_form.py
```

## Como continuar el desarrollo de Estimaciones

Si tu objetivo es implementar `Estimaciones`, el criterio es este:

1. cargar una estructura base real desde SYSPRO
2. copiarla a una estructura editable en memoria
3. aplicar `overrides` del escenario
4. transformar ese escenario a la entrada esperada por el motor
5. recalcular y mostrar costo por nodo y costo total

No hacer esto:

- editar directamente la base de SYSPRO
- copiar formulas del motor en la UI
- mezclar logica de pantalla con acceso SQL

## Dudas que suelen aparecer al entrar

### Por que no se usa solo `B.O.M. cost`

Porque la validacion principal del proyecto esta alineada a la simulacion `What-if`, no al costo historico BOM.

### Por que hay reporte plano y reporte arbol

Porque no responden a la misma necesidad:

- el plano replica la salida visible por componente
- el arbol sirve para acumulacion multinivel y analisis estructural

### Por que `InvWhatIfCost` es importante

Porque en la base actual de validacion es la fuente observada para reproducir la simulacion `What-if`.

## Entregable minimo aceptable de un cambio

Un cambio se considera bien hecho cuando deja:

- documentacion actualizada
- codigo consistente con esa documentacion
- validacion ejecutada o al menos declarada
- impacto en reportes o UI claramente entendido

## Cierre

Este proyecto ya tiene una base documental suficiente para continuar nuevos desarrollos sin arrancar desde cero.

La recomendacion practica es simple:

- empezar siempre por `docs/`
- usar la matriz de trazabilidad para ubicarse rapido
- tocar codigo solo despues de entender la regla funcional que se va a cambiar
