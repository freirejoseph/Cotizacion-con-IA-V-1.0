# Indice de documentacion

## Objetivo

Este directorio concentra toda la documentacion formal del proyecto.

La regla del repositorio es:

- toda la documentacion funcional, tecnica y de referencia vive en `docs/`
- el codigo ejecutable vive en `src/`, `connectors/` y `scripts/`
- `notebooks/` se reserva para exploracion, validacion, prototipos o analisis puntuales

No se debe duplicar documentacion equivalente en otros directorios del repositorio.

## Documentos principales

### Vision general del modelo

- [01. Onboarding para continuar desarrollos del motor](01_onboarding_nuevo_desarrollo_motor_costeo.md)
- [02. Conocimiento consolidado del motor de costeo](02_conocimiento_motor_costeo.md)
- [03. Matriz de trazabilidad del motor de costeo](03_matriz_trazabilidad_motor_costeo.md)
- [04. README tecnico de implementacion](04_readme_tecnico_implementacion_syspromodel.md)
- [05. Modelo de costeo SYSPRO](05_modelo_costeo_syspro.md)
- [06. Mapa de lectura SYSPRO](06_mapa_lectura_syspro.md)
- [07. Tablas SYSPRO en uso](07_tablas_syspro_en_uso.md)
- [08. Flujo de costeo What-if](08_flujo_costeo_whatif_syspro.md)
- [09. Guia operativa del motor de costeo](09_guia_operativa_motor_costeo.md)
- [10. Estimaciones v1.1 - Definicion funcional](10_estimaciones_v1_1_definicion_funcional.md)

## Ruta recomendada de lectura

Para adquirir el conocimiento del proyecto en secuencia, leer estos documentos en este orden:

1. [01. Onboarding para continuar desarrollos del motor](01_onboarding_nuevo_desarrollo_motor_costeo.md)
   Que es el proyecto, como esta organizado y como continuar desarrollos sin empezar desde cero.
2. [02. Conocimiento consolidado del motor de costeo](02_conocimiento_motor_costeo.md)
   Resume que hace el motor, por que se implemento asi, que datos consume y que salidas produce.
3. [03. Matriz de trazabilidad del motor de costeo](03_matriz_trazabilidad_motor_costeo.md)
   Conecta reglas de negocio con tablas de SYSPRO, codigo actual y salidas afectadas.
4. [04. README tecnico de implementacion](04_readme_tecnico_implementacion_syspromodel.md)
   Explica el contexto tecnico, accesos, lineamientos de implementacion y flujo de validacion.
5. [05. Modelo de costeo SYSPRO](05_modelo_costeo_syspro.md)
   Define el modelo funcional general del costeo y sus reglas principales.
6. [06. Mapa de lectura SYSPRO](06_mapa_lectura_syspro.md)
   Detalla que informacion se lee desde la base y como se estructura la lectura del sistema.
7. [07. Tablas SYSPRO en uso](07_tablas_syspro_en_uso.md)
   Lista y justifica las tablas reales que sostienen el modelo actual.
8. [08. Flujo de costeo What-if](08_flujo_costeo_whatif_syspro.md)
   Documenta el flujo seguido para reproducir y validar la salida `What-if` de SYSPRO.
9. [09. Guia operativa del motor de costeo](09_guia_operativa_motor_costeo.md)
   Sirve como manual practico para modificar, validar y extender el motor.
10. [10. Estimaciones v1.1 - Definicion funcional](10_estimaciones_v1_1_definicion_funcional.md)
   Traduce el conocimiento del motor a la futura pantalla de escenarios editables `Estimaciones`.

Si el objetivo es continuar codigo, despues de esta ruta conviene pasar a:

- `src/cotizador_ia/bom_costing.py`
- `connectors/syspro_sqlserver.py`
- `scripts/generate_bom_costing_report.py`
- `scripts/bom_costing_form.py`

### Definiciones funcionales del producto

- [10. Estimaciones v1.1 - Definicion funcional](10_estimaciones_v1_1_definicion_funcional.md)

### Guias operativas del motor

- [09. Guia operativa del motor de costeo](09_guia_operativa_motor_costeo.md)

### Referencias externas y soporte visual

- `Help Syspro sobre Costeo.pdf`
- `Referencias SYSPRO Wip Inv Bom Planning.pdf`
- `Script SQL/`
- `_docx_media/`

## Criterio de organizacion

### Que debe ir en `docs/`

- definiciones funcionales
- decisiones de arquitectura
- reglas del motor
- guias de uso tecnico
- referencias de tablas
- enlaces a pruebas o casos de validacion
- documentacion de versiones futuras

### Que debe ir en `src/`

- logica de negocio
- motor de costeo
- configuracion del paquete

### Que debe ir en `connectors/`

- conectores a fuentes externas
- acceso a SQL Server
- adaptadores de integracion

### Que debe ir en `scripts/`

- programas ejecutables
- utilitarios de linea de comandos
- formularios
- lanzadores operativos

### Que debe ir en `notebooks/`

- exploracion
- validacion puntual
- prototipos rapidos
- analisis interactivo

Los `notebooks` no deben ser la ubicacion principal de programas productivos.

## Regla de mantenimiento

Antes de agregar un documento nuevo:

1. confirmar que no exista otro documento equivalente
2. agregarlo dentro de `docs/`
3. enlazarlo desde este indice cuando sea relevante
4. evitar duplicar contenido funcional ya documentado
