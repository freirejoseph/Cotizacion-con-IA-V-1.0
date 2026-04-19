Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $python) {
    throw "No se encontro python en PATH."
}

Set-Location $projectRoot
& $python.Source "scripts\bom_costing_form.py"
