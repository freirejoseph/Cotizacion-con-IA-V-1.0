@echo off
setlocal
cd /d "%~dp0"

echo ==========================================
echo   Compilando Estimaciones.exe
echo ==========================================
echo.

powershell -ExecutionPolicy Bypass -File ".\scripts\build_estimaciones_exe.ps1"
if errorlevel 1 (
    echo.
    echo La compilacion fallo.
    pause
    exit /b 1
)

echo.
echo Actualizando carpeta Ejecutable...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$dest='Ejecutable'; if (Test-Path $dest) { Remove-Item -LiteralPath $dest -Recurse -Force }; New-Item -ItemType Directory -Path $dest | Out-Null; Copy-Item -Path 'dist\\Estimaciones\\*' -Destination $dest -Recurse -Force; if (Test-Path '.env') { Copy-Item -LiteralPath '.env' -Destination 'Ejecutable\\.env' -Force }"
if errorlevel 1 (
    echo.
    echo El ejecutable se compilo, pero no se pudo actualizar la carpeta Ejecutable.
    pause
    exit /b 1
)

echo.
echo Proceso terminado.
echo Entrega lista en:
echo   %cd%\Ejecutable
echo.
pause
