[CmdletBinding()]
param(
    [string]$OutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

function Test-IsAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-OptionalFeatureState {
    param([Parameter(Mandatory)][string]$FeatureName)

    try {
        $feature = Get-WindowsOptionalFeature -Online -FeatureName $FeatureName -ErrorAction Stop
        return [string]$feature.State
    } catch {
        return 'UNAVAILABLE_OR_NOT_ELEVATED'
    }
}

$os = Get-CimInstance Win32_OperatingSystem
$cpu = @(Get-CimInstance Win32_Processor | Select-Object -First 1)
$systemInfo = @(systeminfo.exe 2>&1 | Out-String)
$hypervisorDetected = ($systemInfo -join "`n") -match '(?i)hypervisor has been detected|un hyperviseur a été détecté'
$hyperVCmdlets = @(Get-Command Get-VM, Get-VMHost, New-VM -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name)
$isAdmin = Test-IsAdministrator

$report = [pscustomobject]@{
    GeneratedAtUtc = [DateTime]::UtcNow.ToString('o')
    ComputerName = [string]$env:COMPUTERNAME
    OsCaption = [string]$os.Caption
    OsVersion = [string]$os.Version
    OsBuild = [string]$os.BuildNumber
    Architecture = [string]$os.OSArchitecture
    IsAdministrator = $isAdmin
    HypervisorDetected = $hypervisorDetected
    HyperVCmdletsAvailable = $hyperVCmdlets
    HyperVFeatureState = Get-OptionalFeatureState -FeatureName 'Microsoft-Hyper-V-All'
    VirtualizationFirmwareEnabled = if ($cpu.Count -gt 0) { $cpu[0].VirtualizationFirmwareEnabled } else { $null }
    SLAT = if ($cpu.Count -gt 0) { $cpu[0].SecondLevelAddressTranslationExtensions } else { $null }
    VMMonitorModeExtensions = if ($cpu.Count -gt 0) { $cpu[0].VMMonitorModeExtensions } else { $null }
    Verdict = 'BLOCKED_OR_NEEDS_ADMIN_CHECK'
}

$hardwareLooksReady = $report.VirtualizationFirmwareEnabled -eq $true -and
    $report.SLAT -eq $true -and
    $report.VMMonitorModeExtensions -eq $true

if ($isAdmin -and $hardwareLooksReady -and $report.HyperVFeatureState -eq 'Enabled' -and $hyperVCmdlets.Count -gt 0) {
    $report.Verdict = 'READY_FOR_HYPER_V_LAB'
}

$json = $report | ConvertTo-Json -Depth 5
if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
    $parent = Split-Path -Parent $OutputPath
    if ($parent) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
    Set-Content -LiteralPath $OutputPath -Value $json -Encoding UTF8
}

$report | Format-List
