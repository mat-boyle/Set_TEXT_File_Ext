<#
Simple per-user installer: copies the helper scripts into
`$env:LOCALAPPDATA\AddTextExtNotepad` and runs the Win10/11 script.

If `SetUserFTA.exe` is present in the source folder it will be copied and used.

Usage (run in an elevated or non-elevated PowerShell session depending on where
you want to install; this script installs to LocalAppData by default):
  powershell -ExecutionPolicy Bypass -File .\install.ps1
#>

Param(
    [string]$InstallDir = "$env:LOCALAPPDATA\AddTextExtNotepad",
    [switch]$RunNow
)

if ($env:OS -notmatch "Windows") {
    Write-Error "This installer must be run on Windows PowerShell."
    exit 1
}

Write-Output "Installing to: $InstallDir"
New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null

$src = Split-Path -Parent $MyInvocation.MyCommand.Definition
$filesToCopy = @('addTextExtNotepad.ps1','addTextExtNotepad-Win10.ps1','README-SetTextToNotepad.md')
foreach ($f in $filesToCopy) {
    $srcPath = Join-Path $src $f
    if (Test-Path $srcPath) {
        Copy-Item -Path $srcPath -Destination $InstallDir -Force
        Write-Output "Copied $f"
    }
}

# Copy SetUserFTA.exe if present
$su = Join-Path $src 'SetUserFTA.exe'
if (Test-Path $su) {
    Copy-Item -Path $su -Destination $InstallDir -Force
    Write-Output "Copied SetUserFTA.exe"
} else {
    Write-Output "SetUserFTA.exe not found in source; Win10/11 method will be unavailable until you place the tool into $InstallDir"
    Write-Output "Open the SetUserFTA releases page in your browser to download:"
    Start-Process 'https://github.com/search?q=SetUserFTA+releases'
}

if ($RunNow) {
    Write-Output "Running installer helper now..."
    $win10Script = Join-Path $InstallDir 'addTextExtNotepad-Win10.ps1'
    if (Test-Path $win10Script) {
        & powershell -NoProfile -ExecutionPolicy Bypass -File $win10Script
    } else {
        Write-Error "Installer helper missing: $win10Script"
    }
} else {
    Write-Output "Install complete. To apply settings now, run:`n  powershell -ExecutionPolicy Bypass -File '$InstallDir\\addTextExtNotepad-Win10.ps1'`nOr place `SetUserFTA.exe` into $InstallDir and then run the script."
}
