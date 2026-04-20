# Empaquetado de Estimaciones a EXE

## Objetivo

Generar un ejecutable de Windows para `Estimaciones` sin depender de Visual Studio Code.

## Salida esperada

El proceso genera:

- `dist/Estimaciones/Estimaciones.exe`
- `dist/Estimaciones/.env`
- `Ejecutable/Estimaciones.exe`
- `Ejecutable/.env`

## Requisito

Tener Python disponible en la maquina de compilacion.

## Opcion recomendada

Ejecutar este comando desde la raiz del proyecto:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\build_estimaciones_exe.ps1
```

## Opcion de un clic

Tambien puedes usar:

- [Compilar Ejecutable.bat](D:\PROYECTOS\Cotizador con IA V 1\Compilar Ejecutable.bat:1)

Ese archivo:

1. compila `Estimaciones.exe`
2. refresca la carpeta `Ejecutable`
3. copia `.env` al paquete final

## Que hace el script

1. valida o instala `PyInstaller`
2. limpia compilaciones previas
3. compila `scripts/bom_costing_form.py`
4. refresca `Ejecutable/`
5. copia `.env` al paquete final

## Entrega al usuario final

Entregar la carpeta completa:

- `dist/Estimaciones/`
- o mas practico: `Ejecutable/`

El usuario debe abrir:

- `Estimaciones.exe`

## Importante

- El ejecutable sigue necesitando acceso a la base de datos SQL Server.
- El archivo `.env` debe acompañar al ejecutable si la conexion depende de esa configuracion.
- La aplicacion busca `.env` en la carpeta del ejecutable, en `configurations/`, en el directorio actual y en la raiz del proyecto.
- Si cambia servidor, usuario, base o credenciales, debes actualizar el `.env` de entrega.

## Alternativa rapida manual

Si prefieres compilar sin el script:

```powershell
python -m pip install pyinstaller
python -m PyInstaller --noconfirm --clean --windowed --name Estimaciones --paths . --paths src --hidden-import connectors.syspro_sqlserver --hidden-import cotizador_ia.bom_costing --hidden-import cotizador_ia.settings --add-data ".env;." scripts\bom_costing_form.py
```
