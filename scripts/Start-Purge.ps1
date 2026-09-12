[CmdletBinding()]
param(
    [string]$OutputDirectory = (Join-Path $PSScriptRoot '..\output'),
    [switch]$CheckOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Test-IsAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-WinReStatus {
    $reagentc = Join-Path $env:SystemRoot 'System32\reagentc.exe'
    if (-not (Test-Path -LiteralPath $reagentc)) {
        return 'UNAVAILABLE'
    }

    $text = (& $reagentc /info 2>&1 | Out-String)
    if ($text -match '(?im)(Windows RE status|Statut de Windows RE|Etat de Windows RE|État de Windows RE)\s*:\s*(Enabled|Activ)') {
        return 'ENABLED'
    }
    if ($text -match '(?im)(Windows RE status|Statut de Windows RE|Etat de Windows RE|État de Windows RE)\s*:\s*(Disabled|Desactiv|Désactiv)') {
        return 'DISABLED'
    }
    return 'UNKNOWN'
}

function Get-DiskPreflight {
    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    $systemDrive = [string]$os.SystemDrive
    $disks = @(Get-CimInstance -ClassName Win32_DiskDrive | ForEach-Object {
        $logicalDisks = @()
        try {
            $partitions = @(Get-CimAssociatedInstance -InputObject $_ -ResultClassName Win32_DiskPartition)
            $logicalDisks = @($partitions | ForEach-Object {
                Get-CimAssociatedInstance -InputObject $_ -ResultClassName Win32_LogicalDisk
            })
        } catch {
            $logicalDisks = @()
        }

        $isUsb = ([string]$_.InterfaceType -eq 'USB') -or ([string]$_.PNPDeviceID -like 'USB*')
        $hasBootVolume = @($logicalDisks | Where-Object {
            $systemDrive -and ([string]$_.DeviceID -eq $systemDrive)
        }).Count -gt 0

        [pscustomobject]@{
            Index = [int]$_.Index
            Model = [string]$_.Model
            SerialNumber = ([string]$_.SerialNumber).Trim()
            InterfaceType = [string]$_.InterfaceType
            SizeBytes = [uint64]$_.Size
            IsUsb = $isUsb
            HasBootVolume = $hasBootVolume
            Volumes = @($logicalDisks | ForEach-Object { [string]$_.DeviceID })
        }
    })

    return [pscustomobject]@{
        SystemDrive = $systemDrive
        Disks = $disks
        InternalDisks = @($disks | Where-Object { -not $_.IsUsb })
        UsbDisks = @($disks | Where-Object { $_.IsUsb })
        BootDisks = @($disks | Where-Object { $_.HasBootVolume })
    }
}

function Write-Report {
    param(
        [Parameter(Mandatory)][string]$Status,
        [Parameter(Mandatory)][object]$Preflight,
        [string]$Reason,
        [string]$NextStep
    )

    New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
    $stamp = (Get-Date).ToUniversalTime().ToString('yyyyMMddTHHmmssZ')
    $path = Join-Path $OutputDirectory "cleanup-$stamp.json"
    $report = [pscustomobject]@{
        SchemaVersion = '1.0'
        GeneratedAtUtc = [DateTime]::UtcNow.ToString('o')
        ComputerName = [Environment]::MachineName
        Status = $Status
        Reason = $Reason
        NextStep = $NextStep
        Windows = [pscustomobject]@{
            Caption = [string]$Preflight.Os.Caption
            Version = [string]$Preflight.Os.Version
            Build = [string]$Preflight.Os.Build
            Architecture = [string]$Preflight.Os.Architecture
            IsAdministrator = [bool]$Preflight.IsAdministrator
            WinRE = [string]$Preflight.WinRE
        }
        Storage = [pscustomobject]@{
            SystemDrive = [string]$Preflight.Disks.SystemDrive
            DiskCount = @($Preflight.Disks.Disks).Count
            Disks = @($Preflight.Disks.Disks)
        }
        Policy = [pscustomobject]@{
            UserFlow = 'Windows Reset / Remove everything / Clean data when offered'
            ExternalMedia = 'BLOCKED_FOR_REVIEW'
            NoCustomIso = $true
            NoAutomaticAccountCreation = $true
        }
    }
    $report | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $path -Encoding UTF8
    return $path
}

$os = Get-CimInstance -ClassName Win32_OperatingSystem
$diskPreflight = Get-DiskPreflight
$preflight = [pscustomobject]@{
    Os = [pscustomobject]@{
        Caption = [string]$os.Caption
        Version = [string]$os.Version
        Build = [string]$os.BuildNumber
        Architecture = [string]$os.OSArchitecture
    }
    IsAdministrator = Test-IsAdministrator
    WinRE = Get-WinReStatus
    Disks = $diskPreflight
}

Write-Host ''
Write-Host '=============================================' -ForegroundColor Cyan
Write-Host ' PURGE WINDOWS - NETTOYAGE COMPLET' -ForegroundColor Cyan
Write-Host '=============================================' -ForegroundColor Cyan
Write-Host ("{0} | Build {1} | {2}" -f $preflight.Os.Caption, $preflight.Os.Build, $preflight.Os.Architecture)
Write-Host ("Administrateur : {0} | WinRE : {1}" -f $preflight.IsAdministrator, $preflight.WinRE)
Write-Host ''
Write-Host 'Le parcours va supprimer les comptes, applications, paramètres et données précédents.' -ForegroundColor Yellow
Write-Host 'Windows redemarrera ensuite et affichera l''ecran de premiere configuration.' -ForegroundColor Yellow
Write-Host ''

foreach ($disk in $diskPreflight.Disks) {
    $sizeGiB = [math]::Round($disk.SizeBytes / 1GB, 1)
    $boot = 'NON-SYSTEME'
    if ($disk.HasBootVolume) { $boot = 'SYSTEME' }
    $bus = [string]$disk.InterfaceType
    if ($disk.IsUsb) { $bus = 'USB' }
    Write-Host ("Disque {0}: {1} | {2} GiB | {3} | {4}" -f $disk.Index, $disk.Model, $sizeGiB, $bus, $boot)
}
Write-Host ''

$blockReason = $null
$bootDiskCount = ($diskPreflight.BootDisks | Measure-Object).Count
$usbDiskCount = ($diskPreflight.UsbDisks | Measure-Object).Count
$internalDiskCount = ($diskPreflight.InternalDisks | Measure-Object).Count
if (-not $preflight.IsAdministrator) {
    $blockReason = 'Une élévation administrateur est requise.'
} else {
    if ($preflight.WinRE -ne 'ENABLED') {
        $blockReason = 'Windows RE n''est pas confirme comme active.'
    } else {
        if ($bootDiskCount -ne 1) {
            $blockReason = 'Le disque systeme n''a pas pu etre identifie de maniere unique.'
        } else {
            if ($usbDiskCount -gt 0) {
                $blockReason = 'Un support USB est connecte. Retirez les supports externes avant de continuer.'
            } else {
                if ($internalDiskCount -lt 1) {
                    $blockReason = 'Aucun disque interne n''a ete identifie.'
                }
            }
        }
    }
}

if ($blockReason) {
    $reportPath = Write-Report -Status 'BLOCKED' -Preflight $preflight -Reason $blockReason -NextStep 'Corriger le précontrôle puis relancer Purge.cmd.'
    Write-Host ''
    Write-Host "BLOCKED — $blockReason" -ForegroundColor Red
    Write-Host "Rapport : $reportPath"
    exit 10
}

if ($CheckOnly) {
    $reportPath = Write-Report -Status 'READY_FOR_OPERATOR_CONFIRMATION' -Preflight $preflight -Reason 'Précontrôle terminé sans modification.' -NextStep 'Relancer sans -CheckOnly pour ouvrir le parcours Windows.'
    Write-Host ''
    Write-Host 'READY — aucun changement effectué.' -ForegroundColor Green
    Write-Host "Rapport : $reportPath"
    exit 0
}

Write-Host 'Cette opération est irréversible pour les données présentes dans le profil Windows.' -ForegroundColor Red
$confirmation = (Read-Host 'Saisir NETTOYER pour ouvrir le parcours de réinitialisation').Trim().ToUpperInvariant()
if ($confirmation -cne 'NETTOYER') {
    $reportPath = Write-Report -Status 'CANCELLED' -Preflight $preflight -Reason 'La confirmation exacte NETTOYER n''a pas ete saisie.' -NextStep 'Aucune action destructive n''a ete lancee.'
    Write-Host "Annulé. Rapport : $reportPath"
    exit 2
}

$reportPath = Write-Report -Status 'RESET_PENDING' -Preflight $preflight -Reason 'Precontrole valide et confirmation recue.' -NextStep 'Dans Windows Reset, choisir Remove everything puis Clean data/Fully clean the drive si propose.'
Write-Host ''
Write-Host 'Précontrôle validé.' -ForegroundColor Green
Write-Host "Journal écrit : $reportPath"
Write-Host ''
Write-Host 'Dans la fenetre Windows qui va s''ouvrir, choisir :' -ForegroundColor Cyan
Write-Host '  1. Réinitialiser ce PC'
Write-Host '  2. Supprimer tout'
Write-Host '  3. Modifier les paramètres, puis activer le nettoyage des données si proposé'
Write-Host '  4. Confirmer la réinitialisation'
Write-Host ''
Write-Host 'Windows redémarrera automatiquement après la confirmation finale.' -ForegroundColor Yellow
# Use Explorer to open the URI explicitly. This avoids a Windows PowerShell
# 5.1 parser/runtime edge case with the URI passed as a positional argument.
Start-Process -FilePath "explorer.exe" -ArgumentList "ms-settings:recovery"
exit 0
