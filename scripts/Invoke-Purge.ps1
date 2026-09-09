[CmdletBinding()]
param(
    [ValidateSet('Inventory', 'Simulate')]
    [string]$Mode = 'Inventory',

    [string]$OutputDirectory = (Join-Path (Get-Location) 'output')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-SafeString {
    param([AllowNull()][object]$Value)
    if ($null -eq $Value) { return $null }
    return [string]$Value
}

function Get-DiskManifest {
    $computer = Get-CimInstance -ClassName Win32_ComputerSystem
    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    $systemDrive = Get-SafeString $os.SystemDrive

    $disks = @(Get-CimInstance -ClassName Win32_DiskDrive | ForEach-Object {
        $partitions = @(Get-CimAssociatedInstance -InputObject $_ -ResultClassName Win32_DiskPartition)
        $logicalDisks = @($partitions | ForEach-Object {
            Get-CimAssociatedInstance -InputObject $_ -ResultClassName Win32_LogicalDisk
        })

        $isUsb = (Get-SafeString $_.InterfaceType) -eq 'USB' -or (Get-SafeString $_.PNPDeviceID) -like 'USB*'
        $hasBootVolume = @($logicalDisks | Where-Object { $systemDrive -and $_.DeviceID -eq $systemDrive }).Count -gt 0

        [pscustomobject]@{
            Index = [int]$_.Index
            DeviceID = Get-SafeString $_.DeviceID
            Model = Get-SafeString $_.Model
            Manufacturer = Get-SafeString $_.Manufacturer
            SerialNumber = (Get-SafeString $_.SerialNumber).Trim()
            InterfaceType = Get-SafeString $_.InterfaceType
            MediaType = Get-SafeString $_.MediaType
            SizeBytes = [uint64]$_.Size
            FirmwareRevision = Get-SafeString $_.FirmwareRevision
            PnpDeviceId = Get-SafeString $_.PNPDeviceID
            IsUsb = $isUsb
            HasBootVolume = $hasBootVolume
            Volumes = @($logicalDisks | ForEach-Object {
                [pscustomobject]@{
                    DeviceID = Get-SafeString $_.DeviceID
                    FileSystem = Get-SafeString $_.FileSystem
                    SizeBytes = [uint64]$_.Size
                    FreeBytes = [uint64]$_.FreeSpace
                }
            })
        }
    })

    [pscustomobject]@{
        SchemaVersion = '0.1'
        GeneratedAtUtc = [DateTime]::UtcNow.ToString('o')
        ComputerName = Get-SafeString $computer.Name
        OsCaption = Get-SafeString $os.Caption
        SystemDrive = $systemDrive
        Policy = [pscustomobject]@{
            DestructiveMode = 'DISABLED_IN_RELEASE_0'
            UsbTargets = 'EXCLUDED'
            UnknownMedia = 'BLOCKED'
            RequirePhysicalEraseProof = $true
        }
        Disks = $disks
    }
}

function Get-Decision {
    param([Parameter(Mandatory)][object]$Disk)

    if ($Disk.IsUsb) {
        return [pscustomobject]@{ Status = 'EXCLUDED'; Reason = 'USB support excluded by default' }
    }
    if ($Disk.HasBootVolume) {
        return [pscustomobject]@{ Status = 'CANDIDATE_REVIEW'; Reason = 'Contains the currently booted volume' }
    }
    if ([string]::IsNullOrWhiteSpace($Disk.Model) -or [string]::IsNullOrWhiteSpace($Disk.SerialNumber)) {
        return [pscustomobject]@{ Status = 'BLOCKED'; Reason = 'Missing stable hardware identity' }
    }
    return [pscustomobject]@{ Status = 'BLOCKED'; Reason = 'Destructive providers are disabled until lab validation' }
}

function Write-Manifest {
    param(
        [Parameter(Mandatory)][object]$Manifest,
        [Parameter(Mandatory)][string]$Path
    )

    $Manifest | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $Path -Encoding UTF8
}

New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
$manifest = Get-DiskManifest
$stamp = (Get-Date).ToUniversalTime().ToString('yyyyMMddTHHmmssZ')
$manifestPath = Join-Path $OutputDirectory "manifest-$stamp.json"
Write-Manifest -Manifest $manifest -Path $manifestPath

Write-Host "PURGE $Mode - inventory only" -ForegroundColor Cyan
Write-Host "Manifest: $manifestPath"
Write-Host "Policy: destructive providers are disabled in Release 0."
Write-Host ''

foreach ($disk in $manifest.Disks) {
    $decision = Get-Decision -Disk $disk
    $sizeGiB = [math]::Round($disk.SizeBytes / 1GB, 1)
    Write-Host ("Disk {0}: {1} | {2} GiB | USB={3} | Boot={4} | {5} | {6}" -f `
        $disk.Index, $disk.Model, $sizeGiB, $disk.IsUsb, $disk.HasBootVolume, $decision.Status, $decision.Reason)
}

if ($Mode -eq 'Simulate') {
    Write-Host ''
    Write-Host 'SIMULATION: no disk, volume, partition, file or registry mutation was attempted.' -ForegroundColor Yellow
}

exit 0
