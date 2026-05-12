---
name: windows-install-development
description: "Install or verify Windows development tools, including developer CLIs, Miniconda-managed Python, editors, Windows Terminal with Conda-activated AI profiles, Oh My Posh, npm global packages, Visual Studio user extensions, API/database tools, and coding agent tools. Use for post-reinstall setup or later partial installs. VS Code extensions sync automatically; Visual Studio workloads/packages are not installed by this skill."
---

# Windows Development Installation

## Purpose

Install, verify, or repair the Windows development environment.

The user is expected to install Codex, NVM for Windows, and Node.js first. This skill verifies that bootstrap state, then installs the remaining developer tools.

## Required References

Read these files before installing anything:

- [references/local-installers-and-pins.md](references/local-installers-and-pins.md)
- [references/windows-terminal.md](references/windows-terminal.md)
- [references/visual-studio-extensions.md](references/visual-studio-extensions.md)
- [references/inventory.md](references/inventory.md)

Default rule: install latest stable online versions with `winget` unless an app is listed as local or pinned.

## Bootstrap Verification

```powershell
nvm list
node -v
npm -v
codex --version
```

If Codex, NVM, or Node.js is missing, stop and tell the user to complete the bootstrap first unless the user explicitly asks Codex to install it.

## Global Install Policy

1. Prefer `winget` silent all-user installation.
2. Prefer the second fixed drive:
   - x64 apps: `[Drive]:\ProgramFiles\<AppName>`
   - x86 apps: `[Drive]:\ProgramFiles(x86)\<AppName>`
3. Use `--scope machine` and `--location` when supported.
4. Use latest stable versions unless an app is listed in `local-installers-and-pins.md`.
5. Do not independently install Visual Studio workloads, Visual Studio component packages, .NET targeting packs, SDK packs, Android/iOS/MacCatalyst packs, IIS Express components, SQL LocalDB, Web Deploy, or redistributables when they are associated installs from Visual Studio or another parent package.
6. Do not install VS Code or Cursor extensions by default because editor extension sync is expected to restore them. Verify sync only.

## Install Core Developer Apps

```powershell
$InstallDrive = 'D'
$ProgramFiles64 = "$InstallDrive`:\ProgramFiles"

$packages = @(
  @{ Id = 'Git.Git'; Name = 'Git' },
  @{ Id = 'GitHub.cli'; Name = 'GitHubCLI' },
  @{ Id = 'Amazon.AWSCLI'; Name = 'AWSCLI' },
  @{ Id = 'Anaconda.Miniconda3'; Name = 'Miniconda3' },
  @{ Id = 'Microsoft.PowerShell'; Name = 'PowerShell7' },
  @{ Id = 'Microsoft.WindowsTerminal'; Name = 'WindowsTerminal' },
  @{ Id = 'Microsoft.VisualStudioCode'; Name = 'VSCode' },
  @{ Id = 'Anysphere.Cursor'; Name = 'Cursor' },
  @{ Id = 'Bruno.Bruno'; Name = 'Bruno' },
  @{ Id = 'DBeaver.DBeaver.Community'; Name = 'DBeaver' },
  @{ Id = 'JanDeDobbeleer.OhMyPosh'; Name = 'OhMyPosh' }
)

foreach ($pkg in $packages) {
  winget install --id $pkg.Id -e `
    --silent --disable-interactivity `
    --scope machine `
    --location (Join-Path $ProgramFiles64 $pkg.Name) `
    --accept-package-agreements --accept-source-agreements
}

winget install --id Microsoft.WSL -e `
  --silent --disable-interactivity `
  --accept-package-agreements --accept-source-agreements
```

## Configure Miniconda Python

Use Miniconda as the Python provider. Do not install standalone CPython, Microsoft Store Python, or a separate Conda distribution from this skill.

```powershell
conda --version
conda config --set auto_activate_base false
conda init powershell
conda run -n base python --version
```

Rules:

- When the user asks for Python, install or verify Miniconda and use conda environments.
- Do not install `Python.Python.3.x`, Microsoft Store Python, or the WindowsApps Python alias from this skill.
- Do not treat Conda as a separate app; use the `conda` command bundled with Miniconda.
- Keep the base environment from auto-activating globally.
- Windows Terminal AI profiles must explicitly activate the selected Conda Python environment before launching the AI CLI. Use `base` unless the user requests another existing Conda environment.
- Use `conda run -n <env> python ...` or `conda activate <env>` for Python commands.
- If the user requests a specific Python version, create or update a Miniconda environment with that version.
- If plain `python` resolves only to WindowsApps, report it as a harmless alias and continue using conda-managed Python.

Restart PowerShell before validating `conda` if initialization changed the profile.

If `conda` is not on `PATH` after installation, locate it under the actual Miniconda install path and report the manual PATH follow-up instead of editing PATH blindly.

Install Visual Studio Community only when missing and explicitly needed. Do not install Visual Studio workloads/packages from this skill; use Visual Studio Installer or a user-provided `.vsconfig` outside this workflow.

## Configure Oh My Posh

After installing Oh My Posh, copy bundled themes to the user profile and enable `powerlevel10k_lean.omp.json`.

```powershell
$SkillRoot = '<path-to-windows-install-development>'
$ThemeSource = Join-Path $SkillRoot 'references\.omp-theme'
$ThemeTarget = Join-Path $env:USERPROFILE '.config\oh-my-posh\themes'
New-Item -ItemType Directory -Force -Path $ThemeTarget | Out-Null
Get-ChildItem -LiteralPath $ThemeSource -File -Filter '*.omp.json' |
  Copy-Item -Destination $ThemeTarget -Force

$ThemePath = Join-Path $ThemeTarget 'powerlevel10k_lean.omp.json'
$ProfileDir = Split-Path -Parent $PROFILE
New-Item -ItemType Directory -Force -Path $ProfileDir | Out-Null
if (-not (Test-Path -LiteralPath $PROFILE)) {
  New-Item -ItemType File -Path $PROFILE -Force | Out-Null
}

$initLine = "oh-my-posh init pwsh --config `"$ThemePath`" | Invoke-Expression"
$profileContent = Get-Content -Raw -LiteralPath $PROFILE -ErrorAction SilentlyContinue
if ($profileContent -notmatch [regex]::Escape('oh-my-posh init pwsh')) {
  Add-Content -LiteralPath $PROFILE -Value "`n$initLine"
}
```

## Configure Windows Terminal

Read [references/windows-terminal.md](references/windows-terminal.md) after installing PowerShell, Windows Terminal, Miniconda, Codex, npm globals, and Oh My Posh.

Configure Windows Terminal to:

- Use PowerShell 7 as the default profile.
- Use Windows Terminal as the default terminal application where this can be done through supported Windows/Terminal settings; otherwise report the manual Settings step.
- Use `FiraCode Nerd Font` as the default terminal font.
- Enable acrylic background with 66 opacity.
- Start centered.
- Keep profile order as PowerShell, Command Prompt, Codex, other AI CLI profiles, Linux distributions, then the remaining profiles.
- Add a Codex profile when `codex` is available.
- Add other AI CLI profiles, such as OpenCode, when the CLI is available.
- Make every AI CLI profile activate the selected Conda environment before starting the AI command so agent-spawned `python` resolves to Miniconda-managed Python.
- Copy icons from `references/icons` to the user terminal icon folder and assign them when matching icon files are present.

## Restore npm Globals

Install latest versions unless pinned.

```powershell
npm install -g @angular/cli opencode-ai
corepack enable
```

Verify `@openai/codex` but do not reinstall it unless missing, because the user bootstraps Codex before invoking this skill.

## Visual Studio Extensions

Read [references/visual-studio-extensions.md](references/visual-studio-extensions.md).

For each listed Visual Studio extension:

1. Prefer a user-provided `.vsix` from `references/installer/`.
2. Otherwise search the Visual Studio Marketplace for the latest compatible version.
3. Download the VSIX from the official Marketplace publisher/source.
4. Install with `VSIXInstaller.exe /quiet`.
5. Report extensions that cannot be found or are incompatible with the installed Visual Studio version.

Do not install Visual Studio workloads, component packages, or SDK/runtime packs as a substitute for extensions.

## Verification

```powershell
git --version
gh --version
aws --version
conda --version
where.exe conda
conda info --envs
conda run -n base python --version
wt --version
node -v
npm -v
npm list -g --depth=0
oh-my-posh --version
code --list-extensions --show-versions
cursor --list-extensions --show-versions
wsl -l -v
```

Report:

- Installed developer apps and actual install paths.
- Packages that ignored `--location` or `--scope machine`.
- Windows Terminal AI profiles and the Conda environment they activate.
- VS Code/Cursor extension sync status.
- Visual Studio user extensions installed or skipped.
- Visual Studio workloads/packages intentionally not installed.
