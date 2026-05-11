---
name: windows-install-basic
description: "Install or verify Windows basic user apps and assets, including bundled fonts, local installers such as Typora, Obsidian, common utilities, and pinned/offline programs. Use for post-reinstall setup or later partial installs of basic non-development software. Does not handle OEM drivers, firmware, Visual Studio packages, or Microsoft built-in apps."
---

# Windows Basic Installation

## Purpose

Install, verify, or repair the basic user environment on a Windows PC.

Use this skill for fonts, non-development utilities, Typora, Obsidian, and local or pinned installers. Use `windows-install-drivers` for drivers and firmware. Use `windows-install-development` for developer tools.

## Required References

Read these files before installing anything:

- [references/local-installers-and-pins.md](references/local-installers-and-pins.md): local installers, fixed versions, and "do not update" exceptions.
- [references/inventory.md](references/inventory.md): observed app inventory and install decisions.

Default rule: items listed in `local-installers-and-pins.md` use the listed local installer or pinned version. All other non-excluded items should be installed from the network at the latest stable version, preferably through `winget`.

## Global Install Policy

1. Exclude Microsoft built-in Windows apps from this skill.
2. Prefer all-user installation with `winget --scope machine`.
3. Prefer silent install for `winget` packages with `--silent --disable-interactivity --accept-package-agreements --accept-source-agreements`.
4. Prefer silent install for local installers when reliable silent arguments are documented.
5. Prefer installing to the second fixed drive, not the system drive:
   - x64 apps: `[Drive]:\ProgramFiles\<AppName>`
   - x86 apps: `[Drive]:\ProgramFiles(x86)\<AppName>`
6. If the target drive is not provided, infer the first non-system fixed drive. If uncertain, ask the user.
7. Use `winget --location` when the installer supports it. If the installer ignores location or scope, report it instead of forcing unsafe moves.
8. Fall back to interactive local installer UI only when silent install is unsupported, silent install fails, or the user explicitly wants to choose options/path manually.
9. For interactive local installers, treat the user-selected installer UI path as authoritative and detect the actual path after installation.
10. Do not install dependency packages independently when they are normally installed by a parent app.

Example install helper:

```powershell
$InstallDrive = 'D'
$ProgramFiles64 = "$InstallDrive`:\ProgramFiles"
$ProgramFiles86 = "$InstallDrive`:\ProgramFiles(x86)"
New-Item -ItemType Directory -Force -Path $ProgramFiles64, $ProgramFiles86 | Out-Null

winget install --id Obsidian.Obsidian -e `
  --silent --disable-interactivity `
  --scope machine `
  --location "$ProgramFiles64\Obsidian" `
  --accept-package-agreements --accept-source-agreements
```

## Workflow

1. Resolve the skill root directory.
2. Read local installer and pinned-version rules.
3. Install bundled fonts.
4. Install local or pinned apps first, especially Typora.
5. Install remaining basic apps with latest stable versions from `winget`.
6. Apply post-install configuration, including Typora registry locking when requested by the local installer rule.
7. Verify app presence and report unsupported location/scope cases.

## Install Bundled Fonts

Install all fonts from `references/fonts`. Prefer all-user font installation when running elevated.

```powershell
$SkillRoot = '<path-to-windows-install-basic>'
$FontSource = Join-Path $SkillRoot 'references\fonts'
$FontRegistry = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts'

Get-ChildItem -LiteralPath $FontSource -File | Where-Object { $_.Extension -in '.ttf', '.otf' } | ForEach-Object {
  $target = Join-Path $env:WINDIR "Fonts\$($_.Name)"
  Copy-Item -LiteralPath $_.FullName -Destination $target -Force
  $kind = if ($_.Extension -ieq '.otf') { 'OpenType' } else { 'TrueType' }
  New-ItemProperty -Path $FontRegistry -Name "$($_.BaseName) ($kind)" -Value $_.Name -PropertyType String -Force | Out-Null
}
```

If the shell is not elevated, install fonts for the current user only and report that machine-wide font installation was skipped.

## Install Typora From Local Installer

Typora must be installed from the local installer, not from the latest online package, unless the user updates the pinned installer rule.

Prefer silent installation with the pinned arguments. Use interactive installation only if silent installation is not wanted, fails, or the user needs to choose the path in the installer UI. In interactive mode, the UI-selected path is authoritative. After installation, detect the actual install location from Windows uninstall registry entries and verify `Typora.exe`.

```powershell
$SkillRoot = '<path-to-windows-install-basic>'
$InstallDrive = 'D'
$TyporaInstaller = Get-ChildItem -LiteralPath (Join-Path $SkillRoot 'references\installer') -Recurse -File -Filter 'typora-setup-*.exe' |
  Sort-Object Name -Descending |
  Select-Object -First 1

Start-Process -FilePath $TyporaInstaller.FullName `
  -ArgumentList "/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /DIR=`"$InstallDrive`:\ProgramFiles\Typora`"" `
  -Wait

$uninstallRoots = @(
  'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
  'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
  'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
)

$typoraEntry = Get-ItemProperty $uninstallRoots -ErrorAction SilentlyContinue |
  Where-Object { $_.DisplayName -match 'Typora' } |
  Select-Object -First 1 DisplayName, DisplayVersion, InstallLocation, UninstallString

$typoraEntry
```

Use interactive mode when needed:

```powershell
Start-Process -FilePath $TyporaInstaller.FullName -Wait
```

After Typora is installed and has created `HKCU\SOFTWARE\Typora`, apply the requested registry denial rule. Export a backup first.

```powershell
$backup = Join-Path $env:USERPROFILE 'typora-registry-before-deny.reg'
& reg.exe export 'HKCU\SOFTWARE\Typora' $backup /y

$keyPath = 'HKCU:\SOFTWARE\Typora'
New-Item -Path $keyPath -Force | Out-Null
$acl = Get-Acl -Path $keyPath
$sidValues = @(
  'S-1-1-0',
  'S-1-5-32-545',
  'S-1-5-32-544',
  'S-1-5-18',
  [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value
) | Select-Object -Unique

foreach ($sidValue in $sidValues) {
  $sid = [System.Security.Principal.SecurityIdentifier]$sidValue
  $rule = New-Object System.Security.AccessControl.RegistryAccessRule(
    $sid,
    [System.Security.AccessControl.RegistryRights]::FullControl,
    [System.Security.AccessControl.InheritanceFlags]::ContainerInherit,
    [System.Security.AccessControl.PropagationFlags]::None,
    [System.Security.AccessControl.AccessControlType]::Deny
  )
  $acl.AddAccessRule($rule)
}

Set-Acl -Path $keyPath -AclObject $acl
```

## Verification

```powershell
winget list Obsidian
Get-ChildItem "$env:WINDIR\Fonts" | Where-Object Name -match 'FiraCode|3270|LXGWWenKai'
Test-Path 'HKCU:\SOFTWARE\Typora'
```

Report:

- Fonts installed globally or only for current user.
- Apps installed from local installers, including the actual path chosen by the installer UI.
- Apps installed from latest online packages.
- Apps skipped because they are Microsoft built-in, dependency packages, or unsupported by silent/global install.
