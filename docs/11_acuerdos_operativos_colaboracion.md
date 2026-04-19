# Acuerdos operativos de colaboracion

## Objetivo

Este documento registra decisiones de trabajo entre el usuario y el asistente para que no dependan de un chat anterior y cualquier continuacion del proyecto mantenga la misma forma de trabajo.

La idea es simple:

- dejar por escrito como trabajamos
- registrar decisiones operativas relevantes
- evitar reaprender acuerdos ya tomados

## Regla principal

Las decisiones repetibles del proyecto deben quedar documentadas en el repositorio.

No deben quedar solo en la conversacion.

## Acuerdos vigentes

### 1. Documentacion como fuente persistente

Cuando una decision afecte la forma de trabajar, la estructura del repo, el flujo de validacion o la transferencia de conocimiento, debe registrarse en `docs/`.

Ejemplos:

- ruta recomendada de lectura
- estructura documental
- flujo de validacion
- acuerdos sobre Git y GitHub
- criterios de organizacion del repo

### 2. Flujo para cambios relevantes

Cuando se haga un cambio relevante, el flujo acordado es:

1. realizar cambios
2. verificar impacto
3. dejar commit local claro
4. preguntar explicitamente al usuario si desea subir el cambio a GitHub
5. hacer `push` solo despues de confirmacion

### 3. Regla de confirmacion previa a GitHub

Para cambios relevantes, el asistente debe preguntar siempre antes de hacer `push` a GitHub.

La confirmacion debe ocurrir despues del commit local y antes del `push`.

### 4. Que se considera un cambio relevante

Por defecto, tratar como relevante:

- cambios en documentacion estructural
- cambios en reglas del motor
- cambios en formulas o tablas usadas
- cambios en estructura de carpetas
- cambios en scripts principales
- cambios que alteren el flujo de trabajo del proyecto

### 5. Donde registrar nuevas decisiones

Si aparece un nuevo acuerdo, se debe documentar en uno de estos lugares:

- en este archivo, si es un acuerdo operativo de colaboracion
- en `docs/README.md`, si cambia la ruta de lectura o la organizacion documental
- en `CHANGELOG.md`, si forma parte visible de una version o reorganizacion relevante
- en el documento tecnico o funcional correspondiente, si la decision afecta el motor o el producto

### 6. Regla de no duplicacion

El acuerdo debe quedar donde mejor ayude a encontrarlo, sin duplicarlo innecesariamente en varios archivos.

### 7. Portada e indice

- `README.md` en la raiz funciona como portada operativa del repositorio
- `docs/README.md` funciona como indice y ruta de lectura del conocimiento del proyecto

## Recomendacion de uso

Cuando se tome una decision nueva, conviene preguntarse:

1. esta decision afecta solo esta tarea o el proyecto en adelante
2. si afecta el proyecto, donde debe quedar escrita
3. quien deberia poder encontrarla en el futuro

Si la respuesta indica continuidad futura, documentarla en el repo.

## Ejemplo ya acordado

Decision:

- despues de cambios relevantes se hace commit local
- antes de subir a GitHub se pide confirmacion al usuario

Estado:

- acuerdo vigente
- registrado en este documento

## Mantenimiento

Este archivo debe actualizarse cuando cambie la forma de colaborar en el proyecto.

No busca documentar reglas tecnicas del motor.
Busca documentar como se trabaja para que el conocimiento operativo no se pierda.
