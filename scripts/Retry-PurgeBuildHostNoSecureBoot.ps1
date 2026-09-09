[CmdletBinding()]
param(
    [string]$VMName = 'PURGE-BUILD-HOST',
    [string]$IsoPath = (Join-Path (Split-Path -Parent $PSScriptRoot) 'Win10_22H2_French_x64v1.iso')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Test-IsAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsAdministrator)) { throw 'Cette opération doit être lancée depuis une console PowerShell administrateur.' }
if (-not (Test-Path -LiteralPath $IsoPath -PathType Leaf)) { throw "ISO introuvable : $IsoPath" }

$vm = Get-VM -Name $VMName -ErrorAction Stop
$iso = Get-Item -LiteralPath $IsoPath
$physical = @(Get-VMHardDiskDrive -VMName $VMName | Where-Object { $_.DiskNumber -ne $null })
if ($physical.Count -gt 0) { throw 'Un disque physique est attaché à la VM. Opération interrompue.' }

if ($vm.State -ne 'Off') { Stop-VM -Name $VMName -TurnOff }
$dvd = Get-VMDvdDrive -VMName $VMName | Select-Object -First 1
if (-not $dvd) { Add-VMDvdDrive -VMName $VMName -Path $iso.FullName | Out-Null; $dvd = Get-VMDvdDrive -VMName $VMName | Select-Object -First 1 }
else { Set-VMDvdDrive -VMName $VMName -ControllerNumber $dvd.ControllerNumber -ControllerLocation $dvd.ControllerLocation -Path $iso.FullName }

Set-VMFirmware -VMName $VMName -EnableSecureBoot Off
Set-VMFirmware -VMName $VMName -FirstBootDevice $dvd
Start-VM -Name $VMName | Out-Null

$report = [pscustomobject]@{
    RetriedAtUtc = [DateTime]::UtcNow.ToString('o')
    VMName = $VMName
    IsoPath = $iso.FullName
    IsoSha256 = (Get-FileHash -LiteralPath $iso.FullName -Algorithm SHA256).Hash
    SecureBoot = 'Off'
    PhysicalDiskAttachments = @()
    State = (Get-VM -Name $VMName).State
}
$reportPath = Join-Path (Split-Path -Parent $PSScriptRoot) 'output\build-host-nosecureboot.json'
New-Item -ItemType Directory -Path (Split-Path -Parent $reportPath) -Force | Out-Null
$report | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $reportPath -Encoding UTF8
$report | ConvertTo-Json -Depth 4
