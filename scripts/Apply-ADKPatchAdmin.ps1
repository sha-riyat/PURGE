[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$PatchRoot,
    [string]$LogRoot = (Join-Path $PSScriptRoot '..\output\adk-patch-logs')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal]::new($identity)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw 'Ce correctif doit être appliqué depuis une console PowerShell administrateur.'
}

$mspFiles = @(Get-ChildItem -LiteralPath $PatchRoot -Recurse -Filter '*.msp' -File | Sort-Object FullName)
if ($mspFiles.Count -eq 0) {
    throw "Aucun fichier .msp trouvé dans : $PatchRoot"
}

New-Item -ItemType Directory -Path $LogRoot -Force | Out-Null
foreach ($msp in $mspFiles) {
    $log = Join-Path $LogRoot ($msp.BaseName + '.log')
    Write-Host "Application du correctif : $($msp.Name)" -ForegroundColor Cyan
    $argumentString = '/qn /norestart /l* "{0}" /p "{1}"' -f $log, $msp.FullName
    $process = Start-Process -FilePath 'msiexec.exe' -ArgumentList $argumentString -Wait -PassThru
    if ($process.ExitCode -notin @(0, 3010)) {
        throw "msiexec a échoué pour $($msp.Name) avec le code $($process.ExitCode)."
    }
}

Write-Host "Correctif ADK appliqué : $($mspFiles.Count) paquet(s)." -ForegroundColor Green
