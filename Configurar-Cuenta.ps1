[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[a-zA-Z0-9][a-zA-Z0-9-]{0,38}$')]
    [string]$Usuario,
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[^\s@]+@[^\s@]+$')]
    [string]$Correo,
    [Parameter(Mandatory = $true)]
    [string]$ClaveSSH,
    [string]$Nombre
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($Nombre)) { $Nombre = $Usuario }
if (-not (Test-Path -LiteralPath $ClaveSSH -PathType Leaf)) {
    throw 'No existe la clave SSH indicada. Preparala primero siguiendo GUIA_GITHUB.md.'
}
if ($ClaveSSH.EndsWith('.pub', [StringComparison]::OrdinalIgnoreCase)) {
    throw 'Indica la ruta de la clave privada, no su archivo .pub. No se leera su contenido.'
}
$remoteUrl = & git -C $projectRoot remote get-url origin
if ($LASTEXITCODE -ne 0 -or $remoteUrl -notmatch '^git@github\.com:[a-zA-Z0-9_.-]+/[a-zA-Z0-9_.-]+$') {
    throw 'Se espera un repositorio con origin SSH en github.com. No se modificara el remoto.'
}
$keyPath = (Resolve-Path -LiteralPath $ClaveSSH).ProviderPath.Replace('\', '/')
# Git passes core.sshCommand to a shell: quote the path as a single argument.
$quotedKey = "'" + $keyPath.Replace("'", "'\''") + "'"
$sshCommand = "ssh -i $quotedKey -o IdentitiesOnly=yes"

$settings = [ordered]@{
    'user.name' = $Nombre
    'user.email' = $Correo
    'core.sshCommand' = $sshCommand
    'codex.githubUser' = $Usuario
}
foreach ($settingName in $settings.Keys) {
    & git -C $projectRoot config --local $settingName $settings[$settingName]
    if ($LASTEXITCODE -ne 0) {
        throw "No se pudo guardar $settingName. Revisa los ajustes locales antes de continuar."
    }
}
Write-Host "Cuenta local seleccionada: $Usuario ($Correo)."
Write-Host 'No se han cambiado remotos, configuracion global, permisos ni credenciales.'
Write-Host 'Comprueba la autenticacion SSH y reinicia Codex con scripts\Iniciar-Codex.ps1.'
