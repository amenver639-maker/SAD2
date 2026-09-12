[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$pythonExe = Join-Path $projectRoot '.venv\Scripts\python.exe'
$mkdocsFile = Join-Path $projectRoot 'mkdocs.yml'

if (-not (Test-Path -LiteralPath $pythonExe -PathType Leaf)) {
    throw 'Falta .venv\Scripts\python.exe. Prepara el entorno siguiendo GUIA_CODEX.md.'
}
if (-not (Test-Path -LiteralPath $mkdocsFile -PathType Leaf)) {
    throw 'No se encuentra mkdocs.yml en la raiz del proyecto.'
}

Push-Location -LiteralPath $projectRoot
try {
    & $pythonExe -m mkdocs build --strict
    if ($LASTEXITCODE -ne 0) {
        throw "La construccion de MkDocs ha fallado (codigo $LASTEXITCODE)."
    }
    Write-Host 'Construccion correcta. No se ha publicado ni creado ningun commit.'
    Write-Host 'La prueba no comprueba todos los enlaces externos ni el aspecto visual.'
}
finally {
    Pop-Location
}
