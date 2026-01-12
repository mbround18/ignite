#!/usr/bin/env pwsh
# Ignite installer script for Windows
# Usage: .\install.ps1 [-Version "v1.0.0"]

param(
    [string]$Version = "latest"
)

$ErrorActionPreference = "Stop"

$Repo = "mbround18/ignite"
$InstallDir = "."

Write-Host "🔥 Installing Ignite..." -ForegroundColor Cyan
Write-Host "   OS: Windows" -ForegroundColor Gray
Write-Host "   Version: $Version" -ForegroundColor Gray

# Detect architecture
$Arch = $env:PROCESSOR_ARCHITECTURE
switch ($Arch) {
    "AMD64" {
        $Arch = "x86_64"
        $BinaryName = "ignite-x86_64-pc-windows-msvc.exe"
    }
    "ARM64" {
        $Arch = "aarch64"
        $BinaryName = "ignite-aarch64-pc-windows-msvc.exe"
    }
    default {
        Write-Host "❌ Unsupported architecture: $Arch" -ForegroundColor Red
        exit 1
    }
}

Write-Host "   Architecture: $Arch" -ForegroundColor Gray

# Construct candidate asset names
$RawAsset = "ignite-x86_64-pc-windows-msvc.exe"
$ArchiveAsset = "ignite-windows-${Arch}.exe.zip"

if ($Arch -eq "aarch64") {
    $RawAsset = "ignite-aarch64-pc-windows-msvc.exe"
}

# Normalize version tag (add leading v if missing)
$VersionTag = $Version
if ($VersionTag -ne "latest" -and -not $VersionTag.StartsWith("v")) {
    $VersionTag = "v$VersionTag"
}

# Build candidate URLs (raw binary first, then archive)
if ($VersionTag -eq "latest") {
    $Urls = @(
        "https://github.com/$Repo/releases/latest/download/$RawAsset",
        "https://github.com/$Repo/releases/latest/download/$ArchiveAsset"
    )
} else {
    $Urls = @(
        "https://github.com/$Repo/releases/download/$VersionTag/$RawAsset",
        "https://github.com/$Repo/releases/download/$VersionTag/$ArchiveAsset"
    )
}

Write-Host ""
Write-Host "📥 Downloading from GitHub..." -ForegroundColor Cyan

$TmpFile = [System.IO.Path]::GetTempFileName()
$TmpDir = Join-Path ([System.IO.Path]::GetTempPath()) ([System.Guid]::NewGuid().ToString())
New-Item -ItemType Directory -Path $TmpDir | Out-Null
$DownloadedUrl = ""

try {
    # Try each candidate URL
    foreach ($u in $Urls) {
        try {
            Invoke-WebRequest -Uri $u -OutFile $TmpFile -UseBasicParsing -ErrorAction Stop
            $DownloadedUrl = $u
            break
        } catch {
            # Continue to next URL
        }
    }
    
    if ([string]::IsNullOrEmpty($DownloadedUrl)) {
        throw "Failed to download Ignite. Tried:`n" + ($Urls | ForEach-Object { "   - $_" } | Out-String)
    }
    
    $OutputPath = Join-Path $InstallDir "ignite.exe"
    
    # If archive, extract; else move raw binary
    if ($DownloadedUrl -like "*.zip") {
        Expand-Archive -Path $TmpFile -DestinationPath $TmpDir -Force
        $BinPath = Get-ChildItem -Path $TmpDir -Recurse -Filter "ignite.exe" | Select-Object -First 1
        if ($BinPath) {
            Move-Item -Path $BinPath.FullName -Destination $OutputPath -Force
        } else {
            throw "Could not find 'ignite.exe' in the archive."
        }
    } else {
        Move-Item -Path $TmpFile -Destination $OutputPath -Force
    }

    Write-Host ""
    Write-Host "✅ Ignite installed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "   Location: $((Resolve-Path $OutputPath).Path)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "📝 Next steps:" -ForegroundColor Cyan
    Write-Host "   1. Add to PATH or run directly: .\ignite.exe --help" -ForegroundColor Gray
    Write-Host ""
    
    # Try to show version
    try {
        $InstalledVersion = & $OutputPath --version 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   Installed version: $InstalledVersion" -ForegroundColor Gray
        }
    } catch {
        # Silently ignore if version check fails
    }
    
} catch {
    Write-Host ""
    Write-Host "❌ Installation failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 Troubleshooting:" -ForegroundColor Yellow
    Write-Host "   - Check if the release exists: https://github.com/$Repo/releases" -ForegroundColor Gray
    Write-Host "   - Verify the binary name matches the release assets" -ForegroundColor Gray
    Write-Host "   - Try specifying a version: .\install.ps1 -Version `"v1.0.0`"" -ForegroundColor Gray
    exit 1
} finally {
    # Cleanup temp files
    if (Test-Path $TmpFile) { Remove-Item $TmpFile -Force -ErrorAction SilentlyContinue }
    if (Test-Path $TmpDir) { Remove-Item $TmpDir -Recurse -Force -ErrorAction SilentlyContinue }
}
