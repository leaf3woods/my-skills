---
name: windows-install-work
description: "Install or verify Windows work apps such as communication, email, remote-access, and daily productivity tools. Use for post-reinstall setup or later partial installs of work software. Typora and Obsidian are handled by windows-install-basic."
---

# Windows Work Installation

## Purpose

Install, verify, or repair daily work applications.

Typora and Obsidian belong to `windows-install-basic`. Developer tools belong to `windows-install-development`.

## Required References

Read these files before installing anything:

- [references/local-installers-and-pins.md](references/local-installers-and-pins.md)
- [references/inventory.md](references/inventory.md)

Default rule: install latest stable online versions with `winget` unless an app is listed as local or pinned.

## Global Install Policy

1. Exclude Microsoft built-in Windows apps.
2. Prefer `winget` silent all-user installation.
3. Prefer the second fixed drive:
   - x64 apps: `[Drive]:\ProgramFiles\<AppName>`
   - x86 apps: `[Drive]:\ProgramFiles(x86)\<AppName>`
4. Use `--location` when supported. If unsupported, report the actual install location.
5. Do not restore account data, chat history, mail stores, SSH keys, or tokens unless the user explicitly provides a source and approves the target.

## Install Pattern

```powershell
$InstallDrive = 'D'
$ProgramFiles64 = "$InstallDrive`:\ProgramFiles"

$packages = @(
  @{ Id = 'Alibaba.DingTalk'; Name = 'DingTalk' },
  @{ Id = 'Tencent.WeChat.Universal'; Name = 'WeChat' },
  @{ Id = 'SlackTechnologies.Slack'; Name = 'Slack' },
  @{ Id = 'NetEase.MailMaster'; Name = 'MailMaster' },
  @{ Id = 'Termius.Termius'; Name = 'Termius' }
)

foreach ($pkg in $packages) {
  winget install --id $pkg.Id -e `
    --silent --disable-interactivity `
    --scope machine `
    --location (Join-Path $ProgramFiles64 $pkg.Name) `
    --accept-package-agreements --accept-source-agreements
}
```

## Verification

```powershell
winget list DingTalk
winget list WeChat
winget list Slack
winget list MailMaster
winget list Termius
```

Manually confirm sign-in state for DingTalk, WeChat, Slack, MailMaster, and Termius.

## Rules

- Do not install Typora or Obsidian here.
- Do not install Outlook for Windows, Microsoft To Do, Phone Link, OneDrive, or other Microsoft built-in apps from this skill.
- Do not copy private app data unless explicitly requested and source/target paths are clear.
