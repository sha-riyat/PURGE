[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$IsoPath,
    [string]$VMName = 'PURGE-BUILD-HOST',
    [string]$BuildRoot = 'C:\Users\Public\Documents\PURGE-BUILD-HOST',
    [UInt64]$MemoryStartupBytes = 4GB,
    [UInt64]$SystemDiskSizeBytes = 80GB,
    [int]$ProcessorCount = 4,
    [switch]$Start
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Test-IsAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsAdministrator)) {
    throw 'La création de la VM doit être lancée depuis une console PowerShell administrateur.'
}

if (-not (Test-Path -LiteralPath $IsoPath -PathType Leaf)) {
    throw "ISO introuvable : $IsoPath"
}

$iso = Get-Item -LiteralPath $IsoPath
if ($iso.Extension -ine '.iso' -or $iso.Length -lt 100MB) {
    throw "Le fichier ne ressemble pas à un ISO valide : $($iso.FullName)"
}

if (Get-VM -Name $VMName -ErrorAction SilentlyContinue) {
    throw "La VM existe déjà : $VMName. Aucune modification automatique n'est effectuée."
}

$switch = Get-VMSwitch -Name 'Default Switch' -ErrorAction SilentlyContinue
if (-not $switch) {
    throw "Le commutateur Hyper-V 'Default Switch' est introuvable."
}

New-Item -ItemType Directory -Path $BuildRoot -Force | Out-Null
$vmRoot = Join-Path $BuildRoot $VMName
New-Item -ItemType Directory -Path $vmRoot -Force | Out-Null
$systemVhd = Join-Path $vmRoot "$VMName-system.vhdx"

if (Test-Path -LiteralPath $systemVhd) {
    throw "Le disque cible existe déjà : $systemVhd"
}

$createdVhd = $false
$createdVm = $false
try {
    New-VHD -Path $systemVhd -Dynamic -SizeBytes $SystemDiskSizeBytes | Out-Null
    $createdVhd = $true

    New-VM -Name $VMName -Generation 2 -MemoryStartupBytes $MemoryStartupBytes -VHDPath $systemVhd -Path $vmRoot | Out-Null
    $createdVm = $true
    Set-VMProcessor -VMName $VMName -Count $ProcessorCount | Out-Null
    $networkAdapters = @(Get-VMNetworkAdapter -VMName $VMName)
    if ($networkAdapters.Count -eq 0) {
        Add-VMNetworkAdapter -VMName $VMName -SwitchName $switch.Name -Name 'Build-Network' | Out-Null
    } else {
        Connect-VMNetworkAdapter -VMName $VMName -Name $networkAdapters[0].Name -SwitchName $switch.Name | Out-Null
    }
    Add-VMDvdDrive -VMName $VMName -Path $iso.FullName | Out-Null
    Set-VM -Name $VMName -AutomaticStopAction ShutDown -AutomaticStartAction Nothing | Out-Null

    $dvd = Get-VMDvdDrive -VMName $VMName | Select-Object -First 1
    Set-VMFirmware -VMName $VMName -EnableSecureBoot On -SecureBootTemplate MicrosoftWindows | Out-Null
    Set-VMFirmware -VMName $VMName -FirstBootDevice $dvd | Out-Null

    if ($Start) {
        Start-VM -Name $VMName | Out-Null
    }

    [pscustomobject]@{
        CreatedAtUtc = [DateTime]::UtcNow.ToString('o')
        VMName = $VMName
        VMRoot = $vmRoot
        IsoPath = $iso.FullName
        IsoSha256 = (Get-FileHash -LiteralPath $iso.FullName -Algorithm SHA256).Hash
        MemoryStartupBytes = $MemoryStartupBytes
        ProcessorCount = $ProcessorCount
        SystemVhd = $systemVhd
        NetworkSwitch = $switch.Name
        PhysicalDiskAttachments = @()
        Started = [bool]$Start
        Status = (Get-VM -Name $VMName).State
    } | ConvertTo-Json -Depth 4
}
catch {
    if ($createdVm -and (Get-VM -Name $VMName -ErrorAction SilentlyContinue)) {
        Remove-VM -Name $VMName -Force
    }
    if ($createdVhd -and (Test-Path -LiteralPath $systemVhd)) {
        Remove-Item -LiteralPath $systemVhd -Force
    }
    throw
}
