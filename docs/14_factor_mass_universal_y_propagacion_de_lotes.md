# 14. Factor Mass universal y propagacion de lotes

## Proposito

Este documento formaliza la regla de negocio para la propagacion de lotes entre nodos de la jerarquia de costeo.

La premisa central es:

- `Mass` existe en todos los codigos
- `Mass` es el factor comun universal de comparacion entre nodos
- la `UDM` solo determina como se expresa la cantidad en cada nodo
- el `Lote estimacion` define la escala de calculo del nodo padre
- los consumos unitarios no se alteran al cambiar el lote

La conversion entre padres, hijos y nietos siempre debe resolverse por equivalencia fisica usando `Mass`, sin importar si el articulo se maneja en `U.`, `KG`, `M`, `ROLL` o cualquier otra unidad de medida.

## Regla funcional

Cuando se modifica el `Lote estimacion` del `Parent Part`, el sistema debe recalcular:

- el lote equivalente del padre
- el lote equivalente de cada hijo
- el lote equivalente de cada nieto
- el total del maestro
- el costo del escenario

El objetivo no es cambiar consumos unitarios, sino mantener coherencia entre:

- el lote economico del nodo
- la cantidad consumida por el padre
- la masa equivalente que consolida el costo del arbol

## Definicion de Mass

`Mass` se interpreta como un factor de normalizacion universal por codigo.

Para cada nodo:

- `Mass` convierte la cantidad expresada en su UDM a una base comun
- esa base comun permite comparar nodos heterogeneos
- la conversion no depende de la unidad comercial visible, sino del factor del maestro

En consecuencia:

- un padre en `U.` puede compararse con un hijo en `KG`
- un nieto en `M` puede participar en el mismo calculo
- toda la jerarquia termina expresandose en una equivalencia fisica homogenea

## Tratamiento de padres e hijos

La logica recomendada es esta:

1. El padre define el lote estimacion de referencia.
2. Ese lote se interpreta en la unidad natural del producto.
3. El valor se normaliza con `Mass` para obtener la masa equivalente del nodo.
4. Cada hijo recibe su propia demanda equivalente desde el padre.
5. Cada hijo mantiene su propio consumo unitario, pero su lote operativo y su costo se calculan con la demanda que hereda.
6. El proceso se repite igual para nietos y niveles inferiores.

Esto significa que el lote del hijo no se copia ciegamente desde el padre.
Se deriva de la demanda real que baja desde el nodo superior, pero siempre expresada en la base comun de `Mass`.

## Regla de consolidacion

El total mostrado en el maestro debe consolidar:

- la masa equivalente de los hijos
- la masa equivalente de los nietos
- los insumos propios del proceso del padre
- las operaciones del padre

La suma final debe reflejar la equivalencia total del arbol y no solo la cantidad visible en pantalla.

## Criterio de visualizacion

Cada nodo debe mostrar dos referencias de control:

- `EBQ maestro`
- `EBQ estimacion`

La primera permite ver el valor base definido en el maestro.
La segunda permite ver el lote efectivo usado en la simulacion.

En el reporte `Jerarquia`, la informacion de un mismo nodo debe permanecer en una sola fila.
La fila de `NODE` debe agrupar:

- codigo del nodo
- descripcion
- warehouse
- ruta
- unidad de medida
- `Mass`
- lote estimado
- kilos estimados
- `EBQ master`
- `EBQ estimado`

Antes de imprimir un nuevo nodo se deja una linea en blanco para separar visualmente los niveles.
Los encabezados del reporte deben mostrarse en negrita en pantalla, impresion y PDF.

Esto aplica tanto a:

- productos terminados
- semielaborados
- adquiridos
- componentes fabricados

## Regla de validacion

Para validar el comportamiento, el reporte jerarquico debe permitir observar:

- el `EBQ` del maestro
- el `EBQ` de estimacion
- el `StockUom`
- el `Mass`
- la cantidad requerida de cada componente
- el costo unitario y el costo total por nodo

La validacion correcta debe confirmar que:

- los consumos unitarios permanecen estables
- los lotes si cambian al variar el padre
- la conversion entre nodos respeta la equivalencia fisica
- el costo total converge con la nueva escala

## Caso de referencia

El codigo `9320000432` se usa como caso de validacion para el arbol de costeo.

En este escenario se debe verificar que:

- el padre muestra su `EBQ` maestro
- el padre muestra su `Lote estimacion`
- cada hijo muestra su lote equivalente
- el total del maestro refleja la suma consolidada

## Criterio tecnico para la implementacion

La implementacion futura debe conservar esta secuencia:

- leer el maestro
- obtener `Mass`, `StockUom` y `Ebq`
- calcular el lote efectivo del padre
- propagar la equivalencia a hijos y nietos
- mantener intactos los consumos unitarios
- consolidar la masa y el costo por nodo

La version 1.0.6 ya usa esta regla en la visualizacion del reporte jerarquico.
Las siguientes iteraciones deben conservar este criterio al modificar calculo, impresion o exportacion.
