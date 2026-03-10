<#
Windows 10/11 helper: uses `SetUserFTA.exe` if available to set user defaults.
If `SetUserFTA.exe` is not present, falls back to the HKCU registry method in
`addTextExtNotepad.ps1`.

Usage:
  powershell -ExecutionPolicy Bypass -File .\addTextExtNotepad-Win10.ps1

Notes:
- Place `SetUserFTA.exe` next to this script to use the Win10/11 method.
- If you don't have `SetUserFTA.exe`, the script will use the registry fallback.
#>

Param(
    [switch]$Force
)

if ($env:OS -notmatch "Windows") {
    Write-Error "This script must be run on Windows PowerShell."
    exit 1
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$setUserFta = Join-Path $scriptDir 'SetUserFTA.exe'

if (Test-Path $setUserFta) {
    Write-Output "Found SetUserFTA.exe — attempting Windows 10/11 user default change."
    try {
        & $setUserFta ".text" "txtfile"
        $rc = $LASTEXITCODE
        if ($rc -eq 0) {
            Write-Output "SetUserFTA completed successfully."
        } else {
            Write-Warning "SetUserFTA exited with code $rc. You may need to run it manually or review its docs."
        }
    } catch {
        Write-Warning "Failed to run SetUserFTA.exe: $_" 
    }
    Write-Output "If mappings didn't update in UI, sign out/in or open Settings -> Apps -> Default apps."
} else {
    Write-Warning "SetUserFTA.exe not found next to script — falling back to registry method."
    $fallback = Join-Path $scriptDir 'addTextExtNotepad.ps1'
    if (Test-Path $fallback) {
        & powershell -NoProfile -ExecutionPolicy Bypass -File $fallback
    } else {
        Write-Error "Fallback script addTextExtNotepad.ps1 not found in $scriptDir"
        exit 1
    }
}
