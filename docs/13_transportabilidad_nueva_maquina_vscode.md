# Transportabilidad del proyecto a una nueva maquina con VS Code

## Objetivo

Dejar este proyecto listo para abrirse en otra maquina Windows usando Visual Studio Code, con los prerequisitos, librerias y configuraciones minimas para:

- ejecutar scripts Python
- abrir el formulario `Estimaciones`
- validar la conexion a SYSPRO
- compilar el ejecutable cuando haga falta

## Alcance

Este instructivo aplica al repositorio completo en modo desarrollo.

La maquina de destino debe tener acceso de red al SQL Server usado por SYSPRO.

## Resumen rapido

1. instalar `Git`
2. instalar `Python 3.10 o superior`
3. instalar `Visual Studio Code`
4. clonar o copiar el repositorio
5. crear un entorno virtual `.venv`
6. instalar dependencias con `pip install -r requirements.txt`
7. crear `.env` a partir de `configurations/.env.example`
8. abrir el proyecto en VS Code y seleccionar el interprete de `.venv`
9. probar conexion y luego abrir `scripts/bom_costing_form.py`

## Version de Python recomendada

- minimo funcional recomendado: `Python 3.10+`
- validado en esta maquina el `2026-04-20`: `Python 3.14.4`

El codigo usa caracteristicas como `X | None` y anotaciones modernas, por lo que no conviene usar Python 3.9 o inferior.

## Prerequisitos del sistema

Instalar en la nueva maquina:

- `Git`
- `Python 3.10 o superior`
- `Visual Studio Code`
- `PowerShell 5+` o `PowerShell 7+`

### Extensiones recomendadas de VS Code

- `Python` de Microsoft
- `Pylance` de Microsoft

## Archivos que si debes llevarte

- todo el repositorio
- `docs/`
- `src/`
- `connectors/`
- `scripts/`
- `configurations/`

## Archivos o carpetas que no hace falta transportar

Estas se regeneran en la nueva maquina:

- `.venv/`
- `build/`
- `dist/`
- `Ejecutable/`
- `__pycache__/`

Tampoco debes copiar un `.env` con credenciales productivas si no corresponde.

## Instalacion en la nueva maquina

Ubicado en la raiz del proyecto:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
```

Si PowerShell bloquea la activacion del entorno virtual:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

## Configuracion de VS Code

1. abrir la carpeta raiz del proyecto en VS Code
2. abrir la paleta de comandos
3. ejecutar `Python: Select Interpreter`
4. elegir `.\.venv\Scripts\python.exe`

Este repositorio ya incluye en `.vscode/settings.json`:

```json
{
  "python.terminal.useEnvFile": true
}
```

Eso ayuda a que la terminal integrada respete el archivo `.env`.

## Variables de entorno

Crear un archivo `.env` en la raiz del proyecto usando como base `configurations/.env.example`.

Opciones soportadas:

### Opcion 1. Cadena completa de conexion

```env
SQLSERVER_CONNECTION_STRING=Data Source=SERVIDOR,1433;Initial Catalog=BASE;User ID=USUARIO;Password=CLAVE;Encrypt=False;TrustServerCertificate=False;Connection Timeout=15;
```

### Opcion 2. Variables separadas

```env
SYSPRO_DB_HOST=192.168.1.5
SYSPRO_DB_PORT=1433
SYSPRO_DB_NAME=EncorePlasti1
SYSPRO_DB_USER=usuario
SYSPRO_DB_PASSWORD=clave
SYSPRO_DB_ENCRYPT=false
SYSPRO_DB_TRUST_SERVER_CERTIFICATE=false
SYSPRO_DB_TIMEOUT_SECONDS=15
```

Si existe `SQLSERVER_CONNECTION_STRING`, el proyecto la usa con prioridad.

## Dependencias Python del proyecto

### Obligatorias

Instaladas por `requirements.txt`:

- `pyinstaller`

### Opcionales

- `pyodbc`

`pyodbc` no es obligatoria para Windows en este proyecto, porque `connectors/syspro_sqlserver.py` usa un fallback por PowerShell para consultar SQL Server cuando se ejecuta en Windows.

En Linux o macOS, o si quieres forzar una conexion ODBC directa, instala tambien:

```powershell
python -m pip install pyodbc
```

## Validacion despues de instalar

Con el entorno virtual activo:

### 1. Probar la conexion

```powershell
python scripts/test_syspro_connection.py
```

### 2. Generar un reporte de prueba

```powershell
python scripts/generate_bom_costing_report.py 9320000432 --batch-qty 12500
```

### 3. Abrir el formulario

```powershell
python scripts/bom_costing_form.py
```

Alternativa:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\run_bom_costing_form.ps1
```

## Compilacion del ejecutable en la nueva maquina

Si tambien quieres generar `Estimaciones.exe`:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\build_estimaciones_exe.ps1
```

Ese proceso:

- valida o instala `pyinstaller`
- compila el formulario
- copia `.env`
- actualiza `Ejecutable/`

## Checklist de traslado

- el repositorio abre sin errores en VS Code
- `.\.venv\Scripts\python.exe` esta seleccionado como interprete
- existe `.env` con datos correctos
- la maquina ve el SQL Server por red
- `python scripts/test_syspro_connection.py` responde correctamente
- `python scripts/bom_costing_form.py` abre la interfaz

## Problemas comunes

### `python` no existe en PATH

Instalar Python marcando la opcion de agregarlo al `PATH`, o usar el ejecutable completo del interprete.

### No abre la ventana del formulario

Verificar que el entorno virtual este activo y que el script se ejecute desde la raiz del proyecto.

### Error de conexion SQL

Revisar:

- host
- puerto
- base
- usuario
- password
- acceso de red desde la nueva maquina

### `pyodbc` falla al instalar

No bloquea el uso normal en Windows de este proyecto. Solo es necesaria si quieres usar la ruta ODBC directa o trabajar fuera de Windows.

## Archivos de referencia utiles

- `README.md`
- `docs/09_guia_operativa_motor_costeo.md`
- `docs/12_empaquetado_estimaciones_exe.md`
- `configurations/.env.example`
- `requirements.txt`
