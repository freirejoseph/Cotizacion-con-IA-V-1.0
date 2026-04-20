$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

$python = Join-Path $projectRoot ".venv\Scripts\python.exe"
if (-not (Test-Path $python)) {
    $python = "python"
}

Write-Host "Instalando/validando PyInstaller..."
& $python -m pip install pyinstaller
if ($LASTEXITCODE -ne 0) {
    throw "No fue posible instalar o validar PyInstaller."
}

Write-Host "Limpiando builds previos..."
if (Test-Path "build") { Remove-Item -LiteralPath "build" -Recurse -Force }
if (Test-Path "dist\Estimaciones") { Remove-Item -LiteralPath "dist\Estimaciones" -Recurse -Force }

Write-Host "Compilando Estimaciones.exe..."
& $python -m PyInstaller `
    --noconfirm `
    --clean `
    --windowed `
    --name "Estimaciones" `
    --paths "." `
    --paths "src" `
    --hidden-import "connectors.syspro_sqlserver" `
    --hidden-import "cotizador_ia.bom_costing" `
    --hidden-import "cotizador_ia.settings" `
    --add-data ".env;." `
    "scripts\bom_costing_form.py"

if ($LASTEXITCODE -ne 0) {
    throw "La compilacion del ejecutable fallo."
}

Write-Host ""
Write-Host "Compilacion completada."
Write-Host "Entrega sugerida:"
Write-Host "  dist\Estimaciones\Estimaciones.exe"
Write-Host "  dist\Estimaciones\.env"
