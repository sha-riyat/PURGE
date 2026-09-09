[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$IsoPath,
    [string]$VMName = 'PURGE-LAB',
    [string]$LabRoot = 'C:\Users\Public\Documents\PURGE-LAB',
    [UInt64]$MemoryStartupBytes = 2GB,
    [UInt64]$SystemDiskSizeBytes = 40GB,
    [UInt64]$DataDiskSizeBytes = 8GB
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Test-IsAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsAdministrator)) {
    throw 'La création du labo Hyper-V doit être lancée depuis une console administrateur.'
}

if (-not (Test-Path -LiteralPath $IsoPath -PathType Leaf)) {
    throw "ISO introuvable : $IsoPath"
}

$iso = Get-Item -LiteralPath $IsoPath
if ($iso.Length -lt 100MB) {
    throw "ISO trop petite pour être considérée comme valide : $($iso.Length) octets."
}

if (Get-VM -Name $VMName -ErrorAction SilentlyContinue) {
    throw "La VM existe déjà : $VMName. Aucune modification automatique n'est effectuée."
}

New-Item -ItemType Directory -Path $LabRoot -Force | Out-Null
$vmRoot = Join-Path $LabRoot $VMName
New-Item -ItemType Directory -Path $vmRoot -Force | Out-Null

$systemVhd = Join-Path $vmRoot "$VMName-system.vhdx"
$dataVhd = Join-Path $vmRoot "$VMName-data.vhdx"

New-VHD -Path $systemVhd -Dynamic -SizeBytes $SystemDiskSizeBytes | Out-Null
New-VHD -Path $dataVhd -Dynamic -SizeBytes $DataDiskSizeBytes | Out-Null

try {
    $vm = New-VM -Name $VMName -Generation 2 -MemoryStartupBytes $MemoryStartupBytes -VHDPath $systemVhd -Path $vmRoot
    Add-VMHardDiskDrive -VMName $VMName -Path $dataVhd | Out-Null
    Add-VMDvdDrive -VMName $VMName -Path $iso.FullName | Out-Null
    Set-VM -Name $VMName -AutomaticStopAction ShutDown -AutomaticStartAction Nothing | Out-Null

    $dvd = Get-VMDvdDrive -VMName $VMName
    $system = Get-VMHardDiskDrive -VMName $VMName | Where-Object { $_.Path -eq $systemVhd }
    $data = Get-VMHardDiskDrive -VMName $VMName | Where-Object { $_.Path -eq $dataVhd }
    Set-VMFirmware -VMName $VMName -FirstBootDevice $dvd | Out-Null

    [pscustomobject]@{
        CreatedAtUtc = [DateTime]::UtcNow.ToString('o')
        VMName = $VMName
        LabRoot = $vmRoot
        IsoPath = $iso.FullName
        SystemVhd = $system.Path
        DataVhd = $data.Path
        NetworkAdapters = @(Get-VMNetworkAdapter -VMName $VMName | Select-Object -ExpandProperty Name)
        PhysicalDiskAttachments = @()
        Status = (Get-VM -Name $VMName).State
    }
}
catch {
    if (Get-VM -Name $VMName -ErrorAction SilentlyContinue) {
        Remove-VM -Name $VMName -Force
    }
    throw
}
