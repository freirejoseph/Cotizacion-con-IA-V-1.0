# Definicion funcional de arranque - Programa de Estimaciones

## 1. Objetivo del documento

Este documento define de forma operativa y detallada el criterio funcional de arranque para el nuevo programa `Estimaciones`.

La intencion es que sirva como especificacion base para desarrollo, de modo que cualquier programador que lo lea pueda implementar la pantalla, el flujo y la integracion con el motor de costeo sin reinterpretar reglas del negocio.

Este documento fija:

- objetivo del programa
- alcance funcional inicial
- estructura de pantalla
- comportamiento esperado
- criterios de edicion
- variables globales
- logica de recalculo
- impacto multinivel
- reglas de versionamiento de escenarios
- integracion con el motor actual

## Estado de implementacion actual

Este documento sigue siendo la definicion funcional del producto, pero al 2026-04-19 ya existe una primera version operativa de `Estimaciones`.

Lo que ya esta implementado:

- pantalla tipo SYSPRO en `scripts/bom_costing_form.py`
- resumen de costo visible
- paneles de `Operaciones` y `Componentes`
- arbol de estimacion
- `Jerarquía` textual
- `Estimar` con barra de avance
- escenario editable en memoria
- acciones `Agregar`, `Editar` y `Eliminar`
- carga de descripciones desde maestro para:
  - `Work center`
  - `N° parte`

Las secciones siguientes deben leerse como criterio funcional objetivo, pero prevalece el estado real del sistema cuando se documentan decisiones ya aprobadas en uso.

Actualizacion operativa al 2026-04-20:

- `Jerarquia` ya permite impresion directa del reporte textual
- existe ayuda integrada con `F1` y menu `Ayuda`
- existe la accion `Actualizar` para aplicar reglas masivas por `ProductClass`
- la descripcion de `ProductClass` se resuelve desde maestro para apoyar la simulacion
- estas reglas siguen viviendo solo en memoria y no alteran la base original de SYSPRO

## 2. Objetivo del programa Estimaciones

El programa `Estimaciones` tiene como objetivo permitir la construccion interactiva de escenarios de costo a partir de una estructura base tomada desde SYSPRO.

El programa no partira desde cero en su primera version.
Partira desde un `ParentPart` existente en SYSPRO y copiara su estructura base para que el usuario pueda modificarla libremente en memoria.

El usuario podra modelar escenarios como:

- cambios de cantidades
- cambios de hijos o subcomponentes
- cambios de operaciones
- cambios de maquinas o centros de trabajo
- cambios de costos
- cambios de tiempos
- cambios de `EBQ`
- cambios de lote de produccion estimado

La salida principal sera un costo simulado final calculado con el motor ya desarrollado.

## 3. Alcance funcional inicial

La primera version funcional del programa `Estimaciones` debe permitir:

1. Tomar un `ParentPart` existente en SYSPRO como estructura base.
2. Copiar sus datos maestros, componentes, subcomponentes y operaciones.
3. Mostrar visualmente la estructura en una pantalla tipo `Estimaciones`, inspirada en la interfaz de SYSPRO.
4. Permitir editar todos los campos que afecten el costo y que ya estan identificados en el motor actual.
5. Recalcular el costo simulado usando el motor de costeo existente.
6. Mostrar el costo simulado final del escenario.
7. Permitir guardar versiones del escenario para referencias futuras.

No es objetivo inicial:

- modificar la base original de SYSPRO
- crear un `ParentPart` inexistente desde cero
- construir comparativos `Base vs Escenario` completos
- procesar instrucciones en lenguaje natural

Estas capacidades quedan previstas para fases posteriores.

## 4. Principio funcional principal

La regla maestra del programa es la siguiente:

> El programa `Estimaciones` permitira editar toda variable del escenario que modifique el costo final segun la logica del motor ya desarrollado.

Esto implica que la edicion no se limita a campos visuales.
Se limita exactamente a los campos que participan en el costo.

## 5. Estructura base del flujo

El flujo operativo esperado es:

1. El usuario selecciona o ingresa un `ParentPart` existente.
2. El sistema consulta SYSPRO y copia:
   - datos del padre
   - ruta
   - componentes
   - subcomponentes multinivel
   - operaciones
   - centros de trabajo
   - variables de costeo asociadas
3. El sistema construye una estructura editable de escenario.
4. El usuario modifica libremente la estructura.
5. El sistema recalcula:
   - al editar campos criticos
   - o al pulsar el boton `Estimar`
6. El sistema muestra el costo simulado final.
7. El usuario puede guardar una version del escenario.

## 6. Estructura visual esperada

La pantalla debe replicar la estructura funcional de la interfaz de `Estimaciones` de SYSPRO.

### 6.1 Cabecera superior

Debe contener, como minimo:

- `ParentPart`
- `Ruta`
- descripcion del padre
- unidad de medida
- lote de estimacion
- `EBQ`
- notas del escenario

### 6.2 Panel izquierdo

Debe existir un arbol de estimacion multinivel.

Este arbol debe mostrar:

- padre
- hijos directos
- nietos
- subniveles adicionales

Debe permitir:

- expandir
- contraer
- seleccionar nodo activo

### 6.3 Panel derecho superior

Debe mostrar las operaciones del nodo seleccionado.

Este panel debe permitir:

- visualizar operaciones del nodo actual
- agregar
- editar
- eliminar
- cambiar secuencia

### 6.4 Panel derecho inferior

Debe mostrar los componentes hijos del nodo seleccionado.

Este panel debe permitir:

- visualizar hijos directos
- agregar
- editar
- eliminar
- reemplazar
- cambiar secuencia

### 6.5 Resumen de costo visible

Debe existir un resumen de costo siempre visible, como minimo con:

- material
- labor
- overhead fijo
- overhead variable
- total del nodo
- total simulado del padre

## 7. Regla de origen de datos

El programa no debe editar directamente la estructura original de SYSPRO.

Siempre deben coexistir dos conceptos:

### 7.1 Estructura base

Es la estructura original leida desde SYSPRO.

Incluye:

- maestro del item
- BOM
- operaciones
- work centres
- datos asociados de costeo

### 7.2 Escenario editable

Es una copia de trabajo derivada de la estructura base.

Sobre esta copia el usuario podra:

- agregar nodos
- eliminar nodos
- cambiar cantidades
- cambiar tasas
- cambiar tiempos
- cambiar costos
- recalcular resultados

La estructura base no debe ser alterada por el programa.

## 8. Restriccion de arranque

El `ParentPart` inicial debe existir en SYSPRO.

En esta primera version:

- no se crea un `ParentPart` nuevo desde cero
- no se trabaja con estructuras enteramente inventadas en el arranque

El flujo inicial es:

- seleccionar `ParentPart` existente
- copiar estructura
- editar escenario

## 9. Campos editables del escenario

## 9.1 Regla general

Todos los campos que afectan el costo y que ya estan identificados por el motor actual deben ser editables.

La edicion no se limita a ciertos paneles.
La edicion sigue la logica del costo.

## 9.2 Campos globales del padre

Estos campos tienen impacto transversal sobre la estructura o sobre el recalculo del escenario.

Campos globales editables propuestos:

- `ParentPart` base solo de lectura luego de cargar
- `Ruta`
- lote de estimacion
- warehouse de referencia, si aplica
- notas del escenario

### Regla critica

Existen campos del padre que afectan a todos los hijos por la logica del motor.

El principal campo global identificado historicamente es:

- `EBQ`

El `EBQ` puede modelarse conceptualmente para responder preguntas del negocio como:

- cuanto costaria producir `25000`
- cuanto costaria producir `50000`
- cuanto costaria producir `100000`

El cambio de `EBQ` impacta cualquier calculo dependiente de:

- `ScrapQuantity / EBQ`
- prorrateo de setup
- startup
- teardown
- overhead fijo
- overhead variable
- costo total acumulado

### Decision operativa vigente

En la version actualmente entregable del formulario:

- `EBQ` se muestra desde `InvMaster`
- `EBQ` queda visible como referencia
- el override operativo del escenario se realiza mediante `Lote estimación`

Esta decision se tomo para mantener una interfaz mas clara en la primera entrega a usuarios.

Decision operativa adicional vigente:

- `F1` o menu `Ayuda` abre una referencia operativa embebida en la interfaz
- `Actualizar` aplica reglas por `ProductClass` sobre el escenario visible
- estas reglas no alteran SYSPRO y solo viven en memoria durante la simulacion actual

## 9.3 Campos editables de componentes

Todos los campos del componente que impactan cantidad o costo deben ser editables.

Campos editables minimos:

- secuencia
- numero de parte
- descripcion
- almacen / warehouse
- cantidad por
- unidad de medida
- categoria de pieza
- `ScrapPercentage`
- `ScrapQuantity`
- `FixedQtyPer`
- indicadores que afecten la logica de consumo
- costo del componente, cuando el escenario requiera override

### Estado actual implementado en componentes

Actualmente ya se pueden editar en la interfaz:

- numero de parte
- descripcion
- almacen
- cantidad unitaria
- unidad de medida
- categoria
- costo unitario

Acciones permitidas sobre componentes:

- agregar hijo
- eliminar hijo
- reemplazar hijo
- editar hijo existente
- mover secuencia

## 9.4 Campos editables de operaciones

Todos los campos que afecten el costo operativo deben ser editables.

Campos editables minimos:

- operacion
- `WorkCentre`
- tipo de operacion
- indice de tasa
- setup
- run
- startup
- teardown
- capacidad
- cola
- movimiento
- subcontrato
- costo de subcontrato
- observaciones
- tasas operativas, si el escenario requiere override manual

### Estado actual implementado en operaciones

Actualmente ya se pueden editar en la interfaz:

- operacion
- `WorkCentre`
- indice de tasa
- run
- setup
- startup
- teardown
- capacidad
- subcontrato

Acciones permitidas sobre operaciones:

- agregar operacion
- eliminar operacion
- editar operacion
- cambiar secuencia
- cambiar maquina
- modificar tiempos
- modificar tasas

## 10. Regla especial al cambiar maquina

Cuando el usuario cambie la maquina o `WorkCentre`, el sistema debe traer automaticamente la informacion maestra asociada desde el centro de trabajo correspondiente.

Esto significa que el cambio de `WorkCentre` no es solo visual.
Debe disparar actualizacion de la descripcion del centro y dejar la base lista para cargar tasas asociadas.

Luego, si se define en la implementacion, podra permitirse override manual adicional.

Pero como criterio funcional:

- el cambio de maquina siempre debe traer automaticamente sus datos maestros base
- la descripcion del centro de trabajo ya debe cargarse en la interfaz actual

## 11. Regla de subensambles repetidos

Cuando un mismo subensamble aparezca repetido en varias partes del arbol y el usuario lo modifique, el cambio debe afectar todas las ocurrencias del mismo codigo.

Esto implica que:

- la estructura no debe tratar ese codigo como ocurrencias aisladas
- el escenario debe propagar el cambio a todas las ramas donde ese mismo codigo exista

Ejemplos de cambios que deben propagarse:

- cambio de cantidad
- cambio de costo
- cambio estructural
- cambio de operaciones
- cambio de maquina
- cambio de tiempos

## 12. Regla de recalculo

El programa debe permitir dos mecanismos de recalculo:

### 12.1 Recalculo inmediato por edicion

Cuando el usuario edite ciertos campos criticos, el sistema debe poder recalcular automaticamente para ir modelando la salida en vivo.

Campos tipicamente criticos:

- lote
- cantidad por
- costo del componente
- `WorkCentre`
- tasas
- tiempos

### 12.2 Recalculo por boton

Tambien debe existir un boton `Estimar`.

Este boton ejecuta el motor de forma explicita sobre el escenario actual.

El objetivo del boton es permitir:

- recalculo completo
- validacion final del escenario modelado
- control manual del usuario

## 13. Regla de salida principal

La salida principal del programa ya no sera el reporte textual actual `Informe costos BOM`.

La salida principal sera la propia pantalla interactiva `Estimaciones`.

La pantalla debe mostrar:

- estructura
- componentes
- operaciones
- costos acumulados
- costo simulado final

## 14. Criterio del costo principal mostrado

El costo relevante a mostrar en `Estimaciones` debe ser el costo simulado final.

No es prioridad inicial mostrar:

- `B.O.M. cost`
- comparativo completo base vs escenario

La salida prioritaria es:

- `Total simulado final`

Este total debe ser el resultado del motor ejecutado sobre la estructura editable del escenario.

## 15. Integracion con el motor actual

El nuevo programa no debe crear una logica paralela.

Debe aprovechar el motor ya desarrollado.

El flujo de integracion esperado es:

1. cargar estructura base desde SYSPRO
2. construir escenario editable
3. transformar el escenario a la estructura esperada por el motor
4. ejecutar el motor
5. recibir resultado de costos
6. reflejarlo en pantalla

La nueva interfaz cambia la forma de entrada y salida.
No debe duplicar innecesariamente las formulas centrales del motor.

## 16. Consideraciones de logica multinivel

El programa debe respetar completamente la logica multinivel del motor.

Esto incluye:

- hijos
- nietos
- subniveles adicionales
- operaciones por nodo
- costos por nodo
- acumulacion ascendente

La regla del motor debe seguir siendo:

```text
TotalNodoPadre =
    SUM(CantidadRequeridaHijo * TotalNodoHijo)
  + CostoOperacionesDelPadre
```

Por tanto:

- cualquier cambio en un hijo debe impactar al nodo padre
- cualquier cambio en un subnivel debe subir hasta la raiz
- el costo final del `ParentPart` debe reflejar todo el arbol editado

## 17. Versionamiento de escenarios

Desde etapas tempranas debe existir versionamiento de escenarios.

Esto significa que el programa no sera solo una simulacion momentanea.
Debe guardar trazabilidad para referencias futuras.

La persistencia se realizara posteriormente en una tabla o grupo de tablas del proyecto mayor.

### Consideraciones funcionales

Cada escenario debe poder guardar, como minimo:

- identificador de escenario
- `ParentPart`
- usuario
- fecha y hora
- version
- notas
- estructura editada
- resultado del costo simulado

No es necesario definir aun el esquema fisico exacto en este documento.
Pero si queda definido que el programa debe nacer preparado para versionar escenarios.

## 18. Contexto de integracion futura

El programa `Estimaciones` formara parte de un proyecto mayor.

En el futuro podra ser invocado por otros programas, pasando parametros como:

- usuario
- `ParentPart`
- otros filtros o claves funcionales

Por ello la implementacion debe considerar desde el inicio:

- separacion entre interfaz y motor
- posibilidad de recibir parametros externos
- capacidad de versionar
- capacidad de persistir escenarios

## 19. Funcionalidad futura prevista pero fuera del arranque

Se deja previsto un frente de interaccion en lenguaje natural, por ejemplo:

- cambiar el costo de todas las materias primas que inicien con `112`
- subir su precio en `12%`
- recalcular impacto en el costo total

Esta funcionalidad no forma parte de la primera implementacion operativa de `Estimaciones`, pero si debe considerarse como direccion futura del producto.

## 20. Requisitos minimos de implementacion

Para considerar implementado correctamente el arranque del programa `Estimaciones`, el desarrollo debe cumplir como minimo:

1. Cargar un `ParentPart` existente.
2. Copiar la estructura real en memoria.
3. Mostrar arbol multinivel navegable.
4. Mostrar panel de operaciones por nodo.
5. Mostrar panel de componentes por nodo.
6. Permitir editar todos los campos que afecten el costo.
7. Soportar impacto global de `EBQ`.
8. Propagar cambios de subensambles repetidos a todas sus ocurrencias.
9. Actualizar tasas automaticamente al cambiar maquina.
10. Recalcular en vivo o con boton `Estimar`.
11. Mostrar costo simulado final.
12. Preparar el escenario para versionamiento futuro.

## 23. Decision operativa sobre jerarquia

La opcion `Maintain hierarchies` no debe cambiar el costo oficial del escenario.

Su funcion es:

- expandir el detalle de componentes y subcomponentes
- permitir inspeccion visual del arbol
- mostrar la jerarquia completa en la ventana `Jerarquía`

El costo oficial mostrado debe seguir la misma logica `What-if` que el reporte textual base.

## 21. Criterio final de construccion

Todo programador que implemente este modulo debe asumir este criterio:

- no se esta construyendo un nuevo reporte
- se esta construyendo una estacion interactiva de modelado de escenarios de costo
- la estructura base viene de SYSPRO
- el usuario puede reescribirla funcionalmente
- el motor actual es el responsable del calculo
- la pantalla `Estimaciones` es la responsable de capturar y mostrar el escenario

## 22. Resumen ejecutivo

El programa `Estimaciones` sera una pantalla interactiva que:

- parte de un `ParentPart` existente
- copia su estructura base
- permite editar todo lo que afecte el costo
- recalcula con el motor ya desarrollado
- muestra el costo simulado final
- prepara la base para versionamiento y crecimiento futuro

Esta definicion se considera la base funcional oficial de arranque para el desarrollo del nuevo programa.
