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
    if ($null -eq $elevated.ExitCode) {
        Write-Host 'ERREUR : le processus administrateur n''a pas retourne de code de sortie.' -ForegroundColor Red
        exit 1
    }
    exit ([int]$elevated.ExitCode)
}

$argumentList = '-NoLogo -NoProfile -ExecutionPolicy Bypass -File "{0}"' -f $startScript
try {
    # Run the worker in a child PowerShell process so its explicit exit code
    # is preserved on Windows PowerShell 5.1 and Windows PowerShell 7.
    $worker = Start-Process -FilePath 'powershell.exe' -ArgumentList $argumentList -Wait -PassThru -NoNewWindow
    if ($null -eq $worker.ExitCode) {
        Write-Host 'ERREUR : le processus PURGE n''a pas retourne de code de sortie.' -ForegroundColor Red
        exit 1
    }
    exit ([int]$worker.ExitCode)
} catch {
    Write-Host ("ERREUR : impossible de lancer le processus PURGE. {0}" -f $_.Exception.Message) -ForegroundColor Red
    exit 1
}
