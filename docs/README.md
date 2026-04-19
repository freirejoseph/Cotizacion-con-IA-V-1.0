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

- [README tecnico de implementacion](README_tecnico_implementacion_syspromodel.md)
- [Modelo de costeo SYSPRO](modelo_costeo_syspro.md)
- [Mapa de lectura SYSPRO](mapa_lectura_syspro.md)
- [Tablas SYSPRO en uso](tablas_syspro_en_uso.md)
- [Flujo de costeo What-if](flujo_costeo_whatif_syspro.md)

### Definiciones funcionales del producto

- [Estimaciones v1.1 - Definicion funcional](estimaciones_v1_1_definicion_funcional.md)

### Guias operativas del motor

- [Guia operativa del motor de costeo](guia_operativa_motor_costeo.md)

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
