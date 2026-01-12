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

# Determine download URL
if ($Version -eq "latest") {
    $DownloadUrl = "https://github.com/$Repo/releases/latest/download/$BinaryName"
    Write-Host "   Fetching: latest release" -ForegroundColor Gray
} else {
    $DownloadUrl = "https://github.com/$Repo/releases/download/$Version/$BinaryName"
    Write-Host "   Fetching: $Version" -ForegroundColor Gray
}

Write-Host ""
Write-Host "📥 Downloading from GitHub..." -ForegroundColor Cyan

try {
    # Download binary
    $OutputPath = Join-Path $InstallDir "ignite.exe"
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $OutputPath -UseBasicParsing
    
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
}
