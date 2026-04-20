$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot
$deliveryRoot = Join-Path $projectRoot "Ejecutable"
$envSource = Join-Path $projectRoot ".env"

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

Write-Host "Actualizando carpeta Ejecutable..."
if (Test-Path $deliveryRoot) {
    try {
        Remove-Item -LiteralPath $deliveryRoot -Recurse -Force
    }
    catch {
        throw "No fue posible actualizar 'Ejecutable'. Cierra Estimaciones.exe si esta abierto y vuelve a intentar."
    }
}
New-Item -ItemType Directory -Path $deliveryRoot | Out-Null
Copy-Item -Path "dist\Estimaciones\*" -Destination $deliveryRoot -Recurse -Force
if (Test-Path $envSource) {
    Copy-Item -LiteralPath $envSource -Destination "dist\Estimaciones\.env" -Force
    Copy-Item -LiteralPath $envSource -Destination (Join-Path $deliveryRoot ".env") -Force
}

Write-Host ""
Write-Host "Compilacion completada."
Write-Host "Entrega sugerida:"
Write-Host "  dist\Estimaciones\Estimaciones.exe"
Write-Host "  dist\Estimaciones\.env"
Write-Host "  Ejecutable\Estimaciones.exe"
