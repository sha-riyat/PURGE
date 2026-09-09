[CmdletBinding()]
param(
    [string]$OutputPath = (Join-Path $PSScriptRoot '..\output\hyperv-admin-check.json')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$feature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
$hostInfo = Get-VMHost
$vms = @(Get-VM)
$switches = @(Get-VMSwitch)

function Get-OptionalPropertyValue {
    param(
        [Parameter(Mandatory)][object]$InputObject,
        [Parameter(Mandatory)][string]$Name
    )

    $property = $InputObject.PSObject.Properties[$Name]
    if ($null -eq $property) {
        return $null
    }
    return $property.Value
}

$report = [pscustomobject]@{
    GeneratedAtUtc = [DateTime]::UtcNow.ToString('o')
    IsAdministrator = $true
    HyperVFeature = [string]$feature.State
    Host = [pscustomobject]@{
        ComputerName = [string]$hostInfo.ComputerName
        VirtualMachinePath = [string]$hostInfo.VirtualMachinePath
        VirtualHardDiskPath = [string]$hostInfo.VirtualHardDiskPath
        LogicalProcessorCount = [int]$hostInfo.LogicalProcessorCount
        MemoryCapacity = [uint64]$hostInfo.MemoryCapacity
    }
    VirtualMachines = @($vms | ForEach-Object {
        [pscustomobject]@{
            Name = [string]$_.Name
            State = [string]$_.State
            Generation = [int]$_.Generation
            Path = [string]$_.Path
        }
    })
    Switches = @($switches | ForEach-Object {
        [pscustomobject]@{
            Name = [string]$_.Name
            SwitchType = [string]$_.SwitchType
            NetAdapterName = [string](Get-OptionalPropertyValue -InputObject $_ -Name 'NetAdapterName')
        }
    })
}

$parent = Split-Path -Parent $OutputPath
if ($parent) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
$report | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $OutputPath -Encoding UTF8
$report | Format-List
