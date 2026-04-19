# Configuraciones del proyecto

Esta carpeta contiene los archivos de configuracion del cotizador SYSPRO.

## Archivos

- `.env.example`: variables de entorno sensibles o dependientes del equipo.
- `database.example.yml`: plantilla principal de conexion y parametros del entorno.
- `database.local.yml`: configuracion local real para desarrollo.
- `database.schema.json`: schema de validacion para la configuracion de base de datos.
- `.env` en la raiz del proyecto: cadena de conexion activa para ejecucion local.

## Regla de uso

- Nunca guardar credenciales reales en el repositorio.
- Tomar los archivos `example` como plantilla para crear versiones locales.
- Mantener aqui solo configuraciones, no logica de negocio.
- Si se actualiza la conexion real, sincronizar `.env`, `database.local.yml` y los docs del modelo.
