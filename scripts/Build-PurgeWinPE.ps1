[CmdletBinding()]
param(
    [string]$BuildRoot = (Join-Path $PSScriptRoot '..\build\winpe-amd64'),
    [string]$IsoPath = (Join-Path $PSScriptRoot '..\output\PurgeWinPE.iso')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Test-IsAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Invoke-Native {
    param(
        [Parameter(Mandatory)][string]$FilePath,
        [Parameter(Mandatory)][string[]]$ArgumentList
    )

    Write-Host ("> {0} {1}" -f $FilePath, ($ArgumentList -join ' ')) -ForegroundColor DarkGray
    & $FilePath @ArgumentList
    if ($LASTEXITCODE -ne 0) {
        throw "Commande échouée avec le code $LASTEXITCODE : $FilePath"
    }
}

if (-not (Test-IsAdministrator)) {
    throw 'Ce build doit être lancé depuis une console PowerShell administrateur.'
}

$kitsRoot = 'C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit'
$env:WinPERoot = Join-Path $kitsRoot 'Windows Preinstallation Environment'
$env:OSCDImgRoot = Join-Path $kitsRoot 'Deployment Tools\amd64\Oscdimg'
$env:DISMRoot = Join-Path $kitsRoot 'Deployment Tools\amd64\DISM'
$copype = Join-Path $kitsRoot 'Windows Preinstallation Environment\copype.cmd'
$makeWinPeMedia = Join-Path $kitsRoot 'Windows Preinstallation Environment\MakeWinPEMedia.cmd'
$dism = Join-Path $env:DISMRoot 'dism.exe'
$ocRoot = Join-Path $kitsRoot 'Windows Preinstallation Environment\amd64\WinPE_OCs'
$mountRoot = Join-Path $BuildRoot 'mount'
$bootWim = Join-Path $BuildRoot 'media\sources\boot.wim'
$purgeTarget = Join-Path $BuildRoot 'media\Purge'
$startnetTarget = Join-Path $BuildRoot 'mount\Windows\System32\startnet.cmd'
$isoParent = Split-Path -Parent $IsoPath

foreach ($path in @($copype, $makeWinPeMedia, $dism, $ocRoot)) {
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Composant WinPE introuvable : $path"
    }
}

if (Test-Path -LiteralPath $BuildRoot) {
    throw "Le dossier de build existe déjà. Pour éviter tout écrasement, choisir un autre BuildRoot : $BuildRoot"
}

New-Item -ItemType Directory -Path $isoParent -Force | Out-Null
$copypeCommand = '"{0}" amd64 "{1}"' -f $copype, $BuildRoot
Invoke-Native -FilePath $env:ComSpec -ArgumentList @('/d', '/c', $copypeCommand)

$mounted = $false
try {
    New-Item -ItemType Directory -Path $mountRoot -Force | Out-Null
    Invoke-Native -FilePath $dism -ArgumentList @('/Mount-Image', "/ImageFile:$bootWim", '/Index:1', "/MountDir:$mountRoot")
    $mounted = $true

    $packages = @('WinPE-WMI', 'WinPE-Scripting', 'WinPE-NetFX', 'WinPE-PowerShell')
    foreach ($package in $packages) {
        $neutral = Join-Path $ocRoot "$package.cab"
        $language = Join-Path $ocRoot "en-us\$($package)_en-us.cab"
        Write-Host "Ajout du composant WinPE : $package (neutral)" -ForegroundColor Cyan
        Invoke-Native -FilePath $dism -ArgumentList @('/Add-Package', "/Image:`"$mountRoot`"", "/PackagePath:`"$neutral`"")
        Write-Host "Ajout du composant WinPE : $package (fr/en-us)" -ForegroundColor Cyan
        Invoke-Native -FilePath $dism -ArgumentList @('/Add-Package', "/Image:`"$mountRoot`"", "/PackagePath:`"$language`"")
    }

    New-Item -ItemType Directory -Path $purgeTarget -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'Start-Purge.ps1') -Destination (Join-Path $purgeTarget 'Start-Purge.ps1') -Force
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'Invoke-Purge.ps1') -Destination (Join-Path $purgeTarget 'Invoke-Purge.ps1') -Force
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'Test-HyperVReadiness.ps1') -Destination (Join-Path $purgeTarget 'Test-HyperVReadiness.ps1') -Force

    @'
@echo off
wpeinit
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File X:\Purge\Start-Purge.ps1
'@ | Set-Content -LiteralPath $startnetTarget -Encoding ASCII

    Invoke-Native -FilePath $dism -ArgumentList @('/Unmount-Image', "/MountDir:$mountRoot", '/Commit')
    $mounted = $false
    Invoke-Native -FilePath $makeWinPeMedia -ArgumentList @('/ISO', $BuildRoot, $IsoPath, '/bootex')
    Write-Host "ISO créée : $IsoPath" -ForegroundColor Green
    Get-FileHash -LiteralPath $IsoPath -Algorithm SHA256
}
finally {
    if ($mounted) {
        try {
            Invoke-Native -FilePath $dism -ArgumentList @('/Unmount-Image', "/MountDir:$mountRoot", '/Discard')
        } catch {
            Write-Warning "Le démontage DISM de secours a échoué : $($_.Exception.Message)"
        }
    }
}
