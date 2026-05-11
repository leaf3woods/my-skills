# Windows Terminal Configuration

Configure Windows Terminal after installing PowerShell 7, Oh My Posh, Codex, and npm global AI CLIs.

## Icon Source

Put user-provided icons in:

```text
windows-install-development/references/icons/
```

Recommended names:

```text
powershell.png
cmd.png
codex.png
opencode.png
wsl.png
ubuntu.png
debian.png
```

When configuring profiles, copy available icons to:

```text
%USERPROFILE%\.config\windows-terminal\icons
```

Use matching icons when present. If no matching icon exists, leave that profile's icon unchanged.

## Required Settings

- Default profile: PowerShell 7.
- Default terminal application: Windows Terminal.
- Default font: `FiraCode Nerd Font`.
- Acrylic background: enabled.
- Opacity: `66`.
- Center on launch: enabled.
- Profile order when profiles exist:
  1. PowerShell 7
  2. Command Prompt
  3. Codex
  4. Other AI CLI profiles, for example OpenCode
  5. Linux distributions / WSL profiles
  6. Remaining profiles

## Settings File Discovery

Prefer the packaged Windows Terminal settings path:

```powershell
$settingsPath = Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'
```

Fallback path:

```powershell
$settingsPath = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows Terminal\settings.json'
```

If neither file exists, launch Windows Terminal once or create the parent directory before writing.

## Profile Rules

PowerShell 7 profile:

- Command line: use the installed `pwsh.exe` path when available.
- Name: `PowerShell`.
- Make this the default profile.

Command Prompt profile:

- Keep the existing Command Prompt profile when present.
- If missing, add `cmd.exe`.

Codex profile:

- Add only when `codex` is available on `PATH`.
- Command line: `pwsh.exe -NoExit -Command codex`.
- Name: `Codex`.

Other AI CLI profiles:

- Add OpenCode only when `opencode` is available on `PATH`.
- Command line: `pwsh.exe -NoExit -Command opencode`.
- Name: `OpenCode`.

Linux distributions:

- Keep existing WSL-generated profiles.
- Sort them after AI CLI profiles.
- Do not create a WSL distro profile unless the distro exists.

## Configuration Procedure

Use JSON parsing instead of string replacement.

1. Back up `settings.json`.
2. Parse JSON with `ConvertFrom-Json`.
3. Ensure `profiles.defaults` exists.
4. Set shared profile defaults:

```json
{
  "font": {
    "face": "FiraCode Nerd Font"
  },
  "useAcrylic": true,
  "opacity": 66
}
```

5. Set global launch/default values:

```json
{
  "centerOnLaunch": true
}
```

6. Add or update PowerShell, Codex, and other AI CLI profiles.
7. Reorder `profiles.list`.
8. Save JSON with sufficient depth.

## Supported Manual Step

Setting Windows Terminal as the Windows default terminal application is OS-version dependent. Prefer supported UI or official settings:

```text
Windows Terminal -> Settings -> Startup -> Default terminal application -> Windows Terminal
```

If there is no reliable supported command on the current OS, report this as a manual step instead of writing undocumented registry values.

## Verification

```powershell
wt --version
Get-Command pwsh, codex, opencode -ErrorAction SilentlyContinue
```

Open Windows Terminal and verify:

- It starts centered.
- The default tab is PowerShell.
- Font uses FiraCode Nerd Font.
- Acrylic and opacity are visible.
- Codex profile appears when Codex is available.
- OpenCode or other AI CLI profiles appear only when available.
- WSL distributions appear after AI CLI profiles when present.
