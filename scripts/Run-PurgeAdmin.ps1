[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Test-IsAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

$startScript = Join-Path $PSScriptRoot 'Start-Purge.ps1'
if (-not (Test-Path -LiteralPath $startScript -PathType Leaf)) {
    throw "Lanceur introuvable : $startScript"
}

if (-not (Test-IsAdministrator)) {
    $argumentList = '-NoLogo -NoProfile -ExecutionPolicy Bypass -File "{0}"' -f $startScript
    $elevated = Start-Process -FilePath 'powershell.exe' -Verb RunAs -ArgumentList $argumentList -Wait -PassThru
    exit $elevated.ExitCode
}

& $startScript
exit $LASTEXITCODE
