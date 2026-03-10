<#
Associates the .text extension with Notepad for the CURRENT USER.
Usage: Run this on Windows PowerShell (does not require elevation for HKCU changes):
  powershell -ExecutionPolicy Bypass -File .\addTextExtNotepad.ps1
#>

Param(
	[switch]$Force
)

if ($env:OS -notmatch "Windows") {
	Write-Error "This script must be run on Windows PowerShell."
	exit 1
}

$ext = ".text"
$progId = "txtfile"
$subKey = "Software\\Classes\\$ext"

try {
	$rk = [Microsoft.Win32.Registry]::CurrentUser.CreateSubKey($subKey)
	if (-not $rk) { throw "Unable to open registry key HKCU:\\$subKey" }
	$rk.SetValue("", $progId, [Microsoft.Win32.RegistryValueKind]::String)
	$rk.Close()
	Write-Output "Associated $ext with ProgID '$progId' for current user."

	# Ensure the ProgID open command points to Notepad (current-user override)
	$notepadPath = "$env:windir\system32\notepad.exe"
	if (Test-Path $notepadPath) {
		$openCmd = '"{0}" "%1"' -f $notepadPath
		$cmdKey = "Software\\Classes\\$progId\\shell\\open\\command"
		$rk2 = [Microsoft.Win32.Registry]::CurrentUser.CreateSubKey($cmdKey)
		$rk2.SetValue("", $openCmd, [Microsoft.Win32.RegistryValueKind]::String)
		$rk2.Close()
		Write-Output "Set open command for $progId to $notepadPath"
	} else {
		Write-Warning "Notepad not found at expected path: $notepadPath"
	}

	# Notify shell to refresh file associations
	& "$env:windir\System32\rundll32.exe" "shell32.dll,SHChangeNotify" 0x08000000 0
	Write-Output "Shell notified to refresh associations."
	Write-Output "If this didn't take effect immediately, sign out/in or use Settings -> Apps -> Default apps."
} catch {
	Write-Error "Failed to set association: $_"
	exit 1
}
