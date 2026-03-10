Set .text default to Notepad (Windows)

This workspace contains two helper scripts and a simple per-user installer:

- `addTextExtNotepad.ps1` — registry-based HKCU method (works as a fallback).
- `addTextExtNotepad-Win10.ps1` — attempts to use `SetUserFTA.exe` (Windows 10/11 recommended).
- `install.ps1` — copies files to `%LOCALAPPDATA%\AddTextExtNotepad` and can run the helper.

Why two methods?
- Windows 10/11 protect the `UserChoice` registry area; changing file defaults reliably on these
  OS versions requires generating a valid hash. The community tool `SetUserFTA.exe` performs that
  operation for you (see its GitHub releases).

How to use
1. On a Windows machine, download this folder and open PowerShell in it.
2. (Optional) Download `SetUserFTA.exe` from its project releases and place it next to the scripts.
   - Search for "SetUserFTA releases" on GitHub (open via the installer if you run it).
3. Run the installer (per-user):

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -RunNow
```

4. If you didn't download `SetUserFTA.exe`, the scripts will apply a HKCU registry fallback which
   may not be honored by Settings UI on Windows 10/11 — sign out/in or open Settings -> Apps -> Default apps
   to check.

Notes and troubleshooting
- If Windows does not show the change immediately, sign out and back in.
- To use the Win10/11 method, place a trusted `SetUserFTA.exe` next to the scripts and rerun the
  `addTextExtNotepad-Win10.ps1` script.
- Always verify downloaded binaries from their official project pages.

Files
- addTextExtNotepad.ps1
- addTextExtNotepad-Win10.ps1
- install.ps1
