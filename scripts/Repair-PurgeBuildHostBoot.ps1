[CmdletBinding()]
param(
    [string]$VMName = 'PURGE-BUILD-HOST',
    [string]$IsoPath = (Join-Path (Split-Path -Parent $PSScriptRoot) 'Win10_22H2_French_x64v1.iso')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$outputRoot = Join-Path $projectRoot 'output'
$errorLogPath = Join-Path $outputRoot 'build-host-repair-error.log'
New-Item -ItemType Directory -Path $outputRoot -Force | Out-Null
trap {
    $_ | Out-String | Set-Content -LiteralPath $errorLogPath -Encoding UTF8
    exit 1
}

function Test-IsAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsAdministrator)) {
    throw 'Cette réparation doit être lancée depuis une console PowerShell administrateur.'
}

if (-not (Test-Path -LiteralPath $IsoPath -PathType Leaf)) {
    throw "ISO introuvable : $IsoPath"
}

$vm = Get-VM -Name $VMName -ErrorAction Stop
$iso = Get-Item -LiteralPath $IsoPath
$physicalDrives = @(Get-VMHardDiskDrive -VMName $VMName | Where-Object { $_.DiskNumber -ne $null })
if ($physicalDrives.Count -gt 0) {
    throw "La VM possède un disque physique attaché. Réparation interrompue par sécurité."
}

if ($vm.State -ne 'Off') {
    Stop-VM -Name $VMName -TurnOff
}

$dvd = Get-VMDvdDrive -VMName $VMName | Select-Object -First 1
if (-not $dvd) {
    Add-VMDvdDrive -VMName $VMName -Path $iso.FullName | Out-Null
    $dvd = Get-VMDvdDrive -VMName $VMName | Select-Object -First 1
} else {
    Set-VMDvdDrive -VMName $VMName -ControllerNumber $dvd.ControllerNumber -ControllerLocation $dvd.ControllerLocation -Path $iso.FullName
}

Set-VMFirmware -VMName $VMName -EnableSecureBoot On -SecureBootTemplate MicrosoftWindows
Set-VMFirmware -VMName $VMName -FirstBootDevice $dvd
Start-VM -Name $VMName | Out-Null

$report = [pscustomobject]@{
    RepairedAtUtc = [DateTime]::UtcNow.ToString('o')
    VMName = $VMName
    IsoPath = $iso.FullName
    IsoSha256 = (Get-FileHash -LiteralPath $iso.FullName -Algorithm SHA256).Hash
    SecureBootTemplate = 'MicrosoftWindows'
    PhysicalDiskAttachments = @()
    State = (Get-VM -Name $VMName).State
}

$reportPath = Join-Path $outputRoot 'build-host-repair.json'
$report | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $reportPath -Encoding UTF8
$report | ConvertTo-Json -Depth 4
