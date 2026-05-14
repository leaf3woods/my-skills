# Windows Terminal Configuration

Configure Windows Terminal after installing PowerShell 7, Miniconda, Oh My Posh, Codex, and npm global AI CLIs.

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
- AI CLI tabs: activate a Conda Python environment before starting the AI CLI.
- Explorer context menu: add `Open Terminal + AI` to open PowerShell plus the first available AI profile in the clicked directory.
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

AI profile Conda activation:

- Use `base` unless the user requests another existing Conda environment.
- Keep global `auto_activate_base` disabled; do not enable it just to support AI tabs.
- Apply activation only to AI CLI profiles, not to the default PowerShell or Command Prompt profiles.
- Ensure `conda init powershell` has run before relying on `conda activate` in a profile command line.
- If `conda` is not available or the selected environment is missing, leave the affected AI profile unchanged and report the follow-up instead of creating an implicit environment.

Use this command shape for AI profiles:

```text
pwsh.exe -NoExit -Command "conda activate <env>; <ai-command>"
```

Codex profile:

- Add only when `codex` is available on `PATH`.
- Command line when Conda is available: `pwsh.exe -NoExit -Command "conda activate base; codex"`.
- Fallback command line when Conda is unavailable: `pwsh.exe -NoExit -Command codex`.
- Name: `Codex`.

Other AI CLI profiles:

- Add OpenCode only when `opencode` is available on `PATH`.
- Command line when Conda is available: `pwsh.exe -NoExit -Command "conda activate base; opencode"`.
- Fallback command line when Conda is unavailable: `pwsh.exe -NoExit -Command opencode`.
- Name: `OpenCode`.
- Apply the same Conda activation pattern to every other AI CLI profile added by this skill.

First AI profile:

- Resolve after adding or updating AI profiles.
- Use the first available AI profile in configured order: `Codex`, then `OpenCode`, then any other AI CLI profile added by this skill.
- If no AI profile exists, skip the Explorer context menu entry and report the missing AI CLI follow-up.

Linux distributions:

- Keep existing WSL-generated profiles.
- Sort them after AI CLI profiles.
- Do not create a WSL distro profile unless the distro exists.

## Explorer Context Menu

Add a custom user-level Explorer entry instead of editing the built-in Windows `Open in Terminal` verb. The built-in verb is OS/Windows Terminal managed and may already pass a starting directory argument. Do not rely on `startupActions` for this use case because Windows Terminal only applies startup actions when no command-line arguments are supplied.

Create the entry under these user registry paths:

```text
HKCU:\Software\Classes\Directory\Background\shell\OpenTerminalWithAi
HKCU:\Software\Classes\Directory\shell\OpenTerminalWithAi
HKCU:\Software\Classes\Drive\shell\OpenTerminalWithAi
```

Use these command shapes:

```text
"<wt.exe>" new-tab -p "PowerShell" -d "%V" ; new-tab -p "<FirstAiProfile>" -d "%V"
"<wt.exe>" new-tab -p "PowerShell" -d "%1" ; new-tab -p "<FirstAiProfile>" -d "%1"
```

Use `%V` for `Directory\Background` and `%1` for `Directory` and `Drive`. Quote profile names and directory placeholders.

Reference implementation:

```powershell
$profileNames = @($settings.profiles.list | Where-Object { $_.name } | ForEach-Object { $_.name })
$aiProfilePreference = @('Codex', 'OpenCode')
$firstAiProfile = $aiProfilePreference |
  Where-Object { $profileNames -contains $_ } |
  Select-Object -First 1

if ($firstAiProfile) {
  $wt = (Get-Command wt.exe -ErrorAction SilentlyContinue).Source
  if (-not $wt) { $wt = 'wt.exe' }

  $entries = @(
    @{ Path = 'HKCU:\Software\Classes\Directory\Background\shell\OpenTerminalWithAi'; DirArg = '%V' },
    @{ Path = 'HKCU:\Software\Classes\Directory\shell\OpenTerminalWithAi'; DirArg = '%1' },
    @{ Path = 'HKCU:\Software\Classes\Drive\shell\OpenTerminalWithAi'; DirArg = '%1' }
  )

  foreach ($entry in $entries) {
    New-Item -Path $entry.Path -Force | Out-Null
    Set-Item -Path $entry.Path -Value 'Open Terminal + AI'
    New-ItemProperty -Path $entry.Path -Name 'Icon' -Value $wt -PropertyType String -Force | Out-Null

    $commandKey = Join-Path $entry.Path 'command'
    New-Item -Path $commandKey -Force | Out-Null
    $command = "`"$wt`" new-tab -p `"PowerShell`" -d `"$($entry.DirArg)`" ; new-tab -p `"$firstAiProfile`" -d `"$($entry.DirArg)`""
    Set-Item -Path $commandKey -Value $command
  }
}
```

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

6. Resolve the AI profile Conda environment with `conda info --envs`; default to `base`.
7. Add or update PowerShell, Codex, and other AI CLI profiles.
8. For every AI CLI profile, set the command line to activate the selected Conda environment before launching the AI CLI.
9. Reorder `profiles.list`.
10. Save JSON with sufficient depth.
11. Add the user-level Explorer context menu entry when a first AI profile exists.

## Supported Manual Step

Setting Windows Terminal as the Windows default terminal application is OS-version dependent. Prefer supported UI or official settings:

```text
Windows Terminal -> Settings -> Startup -> Default terminal application -> Windows Terminal
```

If there is no reliable supported command on the current OS, report this as a manual step instead of writing undocumented registry values.

If the user asks to replace the built-in `Open in Terminal` context menu behavior, report that as OS-managed and use the custom `Open Terminal + AI` entry unless they explicitly accept the risk of unsupported registry changes.

## Verification

```powershell
wt --version
Get-Command pwsh, conda, codex, opencode -ErrorAction SilentlyContinue
conda info --envs
Get-ItemProperty HKCU:\Software\Classes\Directory\Background\shell\OpenTerminalWithAi -ErrorAction SilentlyContinue
```

Open Windows Terminal and verify:

- It starts centered.
- The default tab is PowerShell.
- Font uses FiraCode Nerd Font.
- Acrylic and opacity are visible.
- Codex profile appears when Codex is available and its command line activates the selected Conda environment.
- OpenCode or other AI CLI profiles appear only when available, and each AI profile activates the selected Conda environment.
- WSL distributions appear after AI CLI profiles when present.
- Right-click a folder background and choose `Open Terminal + AI`; verify it opens PowerShell and the first AI profile as two tabs in that directory.
