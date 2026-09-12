[CmdletBinding(DefaultParameterSetName = 'Inicio')]
param(
    [Parameter(ParameterSetName = 'Login')]
    [switch]$LoginGitHub,
    [Parameter(ParameterSetName = 'Diagnostico')]
    [switch]$Diagnostico
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot

function Read-LocalGitSetting([string]$Name) {
    $value = & git -C $projectRoot config --local --get $Name
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace([string]$value)) {
        throw "Falta el ajuste local '$Name'. Consulta GUIA_GITHUB.md."
    }
    return ([string]$value).Trim()
}

$githubUser = Read-LocalGitSetting 'codex.githubUser'
if ($githubUser -notmatch '^[a-zA-Z0-9][a-zA-Z0-9-]{0,38}$') {
    throw 'codex.githubUser no tiene formato de usuario GitHub.'
}
$commitName = Read-LocalGitSetting 'user.name'
$commitEmail = Read-LocalGitSetting 'user.email'
$sshCommand = Read-LocalGitSetting 'core.sshCommand'
$remoteUrl = & git -C $projectRoot remote get-url origin
if ($LASTEXITCODE -ne 0 -or $remoteUrl -notmatch '^git@github\.com:([a-zA-Z0-9_.-]+/[a-zA-Z0-9_.-]+?)(?:\.git)?$') {
    throw 'Este iniciador espera origin con formato git@github.com:PROPIETARIO/REPO.git.'
}
$githubRepo = $Matches[1]

# These overrides would invalidate the selected profile. Never print their values.
foreach ($variableName in @('GH_TOKEN', 'GITHUB_TOKEN', 'GIT_SSH_COMMAND', 'GIT_SSH',
    'GIT_AUTHOR_NAME', 'GIT_AUTHOR_EMAIL', 'GIT_COMMITTER_NAME', 'GIT_COMMITTER_EMAIL')) {
    if (-not [string]::IsNullOrEmpty([Environment]::GetEnvironmentVariable($variableName, 'Process'))) {
        throw "La variable $variableName esta definida y puede sustituir la identidad del proyecto. Revisala sin compartir su valor."
    }
}
if ([string]::IsNullOrWhiteSpace($env:APPDATA)) {
    throw 'No se encuentra APPDATA. Este iniciador esta preparado para Windows.'
}
$profileDirectory = Join-Path $env:APPDATA "GitHub CLI\cuentas\$githubUser"
$previousEnvironment = @{}
foreach ($variableName in @('GH_CONFIG_DIR', 'GH_HOST', 'GH_REPO')) {
    $previousEnvironment[$variableName] = [Environment]::GetEnvironmentVariable($variableName, 'Process')
}

Push-Location -LiteralPath $projectRoot
try {
    $env:GH_CONFIG_DIR = $profileDirectory
    $env:GH_HOST = 'github.com'
    $env:GH_REPO = $githubRepo
    Write-Host "Proyecto: $githubRepo"
    Write-Host "Cuenta GitHub esperada: $githubUser"
    Write-Host "Autor local de commits: $commitName <$commitEmail>"
    Write-Host "Perfil de GitHub CLI: $profileDirectory"

    if ($Diagnostico) {
        Write-Host 'Diagnostico local: no se ha probado SSH ni la sesion remota de GitHub.'
        return
    }
    if ($LoginGitHub) {
        if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
            throw 'Falta GitHub CLI (gh). Consulta GUIA_GITHUB.md.'
        }
        Write-Host "Inicia sesion en el navegador con $githubUser. No se subiran claves SSH."
        & gh auth login --hostname github.com --git-protocol ssh --web --skip-ssh-key
        if ($LASTEXITCODE -ne 0) { throw 'No se pudo iniciar sesion en GitHub CLI.' }
        $authenticatedUser = & gh api user --jq '.login'
        if ($LASTEXITCODE -ne 0 -or ([string]$authenticatedUser).Trim() -ine $githubUser) {
            throw 'La cuenta autenticada no coincide o no pudo verificarse. No se iniciara Codex.'
        }
        Write-Host 'Cuenta verificada. Ya puedes ejecutar el iniciador sin -LoginGitHub.'
        return
    }
    if (-not (Get-Command codex -ErrorAction SilentlyContinue)) {
        throw 'No se encuentra Codex CLI en PATH.'
    }
    Write-Host 'Abriendo Codex. Antes de usar gh, el agente debe verificar la cuenta remota.'
    & codex
    if ($LASTEXITCODE -ne 0) { throw "Codex termino con codigo $LASTEXITCODE." }
}
finally {
    foreach ($variableName in $previousEnvironment.Keys) {
        [Environment]::SetEnvironmentVariable($variableName, $previousEnvironment[$variableName], 'Process')
    }
    Pop-Location
}
