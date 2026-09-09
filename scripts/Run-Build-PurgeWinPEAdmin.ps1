[CmdletBinding()]
param(
    [string]$ProjectRoot = (Split-Path -Parent $PSScriptRoot),
    [string]$BuildRoot = (Join-Path (Split-Path -Parent $PSScriptRoot) 'build\winpe-amd64'),
    [string]$IsoPath = (Join-Path (Split-Path -Parent $PSScriptRoot) 'output\PurgeWinPE.iso')
)

$ErrorActionPreference = 'Stop'
$logPath = Join-Path $ProjectRoot 'output\winpe-build-admin.log'
$buildScript = Join-Path $ProjectRoot 'scripts\Build-PurgeWinPE.ps1'
New-Item -ItemType Directory -Path (Split-Path -Parent $logPath) -Force | Out-Null
"Started: $(Get-Date -Format o)" | Set-Content -LiteralPath $logPath -Encoding UTF8

try {
    & $buildScript -BuildRoot $BuildRoot -IsoPath $IsoPath *>&1 | Tee-Object -FilePath $logPath -Append
    $code = $LASTEXITCODE
    "ExitCode: $code" | Add-Content -LiteralPath $logPath -Encoding UTF8
    exit $code
} catch {
    $_ | Out-String | Add-Content -LiteralPath $logPath -Encoding UTF8
    exit 1
}
