# Windows Install Software Index

Use this index in fresh conversations to route a requested app to the correct module and install rule.

Rules:

- If the user asks to install one specific app, locate it here first.
- Then read the target module skill and module references before installing.
- If an app is not listed here, search online only when the relevant module allows latest online installs and the user approves installing an unlisted app.
- Local installer or pinned rules always override latest online installation.
- Do not rely on prior conversation context for software names, package IDs, local installer paths, or post-install rules.
- Use this index for both post-reinstall setup and later one-off installs.

## Basic Module

| App or item | Module | Install source | Rule |
| --- | --- | --- | --- |
| Fonts | `windows-install-basic` | `windows-install-basic/references/fonts/` | Install bundled fonts |
| 3270 Nerd Font | `windows-install-basic` | `windows-install-basic/references/fonts/3270NerdFont-Regular.ttf` | Install bundled font |
| Fira Code | `windows-install-basic` | `windows-install-basic/references/fonts/FiraCode-Regular.ttf` | Install bundled font |
| Fira Code Nerd Font | `windows-install-basic` | `windows-install-basic/references/fonts/FiraCodeNerdFont-Regular.ttf` | Install bundled font |
| LXGW WenKai | `windows-install-basic` | `windows-install-basic/references/fonts/LXGWWenKai-Regular.ttf` | Install bundled font |
| Typora | `windows-install-basic` | `windows-install-basic/references/installer/Typora v0.11.18/typora-setup-x64-0.11.18.exe` | Local pinned installer; silent-first; interactive fallback accepts user-selected path; lock `HKCU\SOFTWARE\Typora` after install |
| Obsidian | `windows-install-basic` | `winget` ID `Obsidian.Obsidian` | Latest stable online |
| Clash Verge | `windows-install-basic` | `winget` ID `ClashVergeRev.ClashVergeRev` | Latest stable online |
| ChatGPT Desktop | `windows-install-basic` | Search `OpenAI.ChatGPT` / Store source if needed | Latest stable online if available; report MSIX location limitations |
| Snipaste | `windows-install-basic` | Search `Snipaste` with `winget` if requested | Latest stable online if available; report MSIX location limitations |
| DevToys | `windows-install-basic` | Search `DevToys` with `winget` if requested | Latest stable online if available; report MSIX location limitations |

## Work Module

| App | Module | Install source | Rule |
| --- | --- | --- | --- |
| DingTalk | `windows-install-work` | `winget` ID `Alibaba.DingTalk` | Latest stable online |
| WeChat | `windows-install-work` | `winget` ID `Tencent.WeChat.Universal` | Latest stable online; report MSIX/location limitations |
| Slack | `windows-install-work` | `winget` ID `SlackTechnologies.Slack` | Latest stable online |
| NetEase MailMaster | `windows-install-work` | `winget` ID `NetEase.MailMaster` | Latest stable online |
| Termius | `windows-install-work` | `winget` ID `Termius.Termius` | Latest stable online |

## Development Module

| App or item | Module | Install source | Rule |
| --- | --- | --- | --- |
| Git | `windows-install-development` | `winget` ID `Git.Git` | Latest stable online |
| GitHub CLI | `windows-install-development` | `winget` ID `GitHub.cli` | Latest stable online |
| AWS CLI | `windows-install-development` | `winget` ID `Amazon.AWSCLI` | Latest stable online |
| Python | `windows-install-development` | `winget` ID `Anaconda.Miniconda3` | Install or verify Miniconda-managed Python; create/use conda environments for requested Python versions |
| Miniconda | `windows-install-development` | `winget` ID `Anaconda.Miniconda3` | Latest stable online; keep base auto-activation disabled by default |
| PowerShell 7 | `windows-install-development` | `winget` ID `Microsoft.PowerShell` | Latest stable online |
| Windows Terminal | `windows-install-development` | `winget` ID `Microsoft.WindowsTerminal` | Latest stable online; configure profiles, FiraCode Nerd Font, acrylic opacity 66, centered launch, default PowerShell profile |
| VS Code | `windows-install-development` | `winget` ID `Microsoft.VisualStudioCode` | Latest stable online; extensions sync automatically |
| Cursor | `windows-install-development` | `winget` ID `Anysphere.Cursor` | Latest stable online; extensions sync/manual |
| Bruno | `windows-install-development` | `winget` ID `Bruno.Bruno` | Latest stable online |
| DBeaver Community | `windows-install-development` | `winget` ID `DBeaver.DBeaver.Community` | Latest stable online |
| WSL | `windows-install-development` | `winget` ID `Microsoft.WSL` | Latest stable online; system-managed location |
| Oh My Posh | `windows-install-development` | `winget` ID `JanDeDobbeleer.OhMyPosh` | Latest stable online; copy bundled themes and enable `powerlevel10k_lean.omp.json` |
| Angular CLI | `windows-install-development` | npm package `@angular/cli` | Install latest global npm package unless pinned |
| OpenCode | `windows-install-development` | npm package `opencode-ai` | Install latest global npm package unless pinned |
| Codex CLI | `windows-install-development` | npm package `@openai/codex` | Bootstrap prerequisite; verify, do not reinstall by default |
| Windows Terminal Codex profile | `windows-install-development` | Windows Terminal settings | Add profile when `codex` is available; use icon from `references/icons` when provided |
| CSharpier for Visual Studio | `windows-install-development` | Visual Studio Marketplace or local VSIX | Install latest compatible Visual Studio extension |
| File Icons for Visual Studio | `windows-install-development` | Visual Studio Marketplace or local VSIX | Install latest compatible Visual Studio extension |
| IndentRainbow for Visual Studio | `windows-install-development` | Visual Studio Marketplace or local VSIX | Install latest compatible Visual Studio extension |
| One Dark Pro 2026 for Visual Studio | `windows-install-development` | Visual Studio Marketplace or local VSIX | Install latest compatible Visual Studio extension |
| Open in Visual Studio Code | `windows-install-development` | Visual Studio Marketplace or local VSIX | Install latest compatible Visual Studio extension |
| Rainbow Braces for Visual Studio | `windows-install-development` | Visual Studio Marketplace or local VSIX | Install latest compatible Visual Studio extension |

## Drivers Module

| Item | Module | Install source | Rule |
| --- | --- | --- | --- |
| Dell SupportAssist | `windows-install-drivers` | `winget` / OEM source | Optional Dell tooling; install only for Dell driver audit or when user requests |
| Dell/OEM firmware | `windows-install-drivers` | Windows Update or OEM support tool/page | Audit first; update only when missing, abnormal, or explicitly approved |
| Intel platform/display drivers | `windows-install-drivers` | Windows Update, OEM, or official vendor source | Do not update working drivers by default |
| MediaTek Wi-Fi/Bluetooth drivers | `windows-install-drivers` | Windows Update, OEM, or official vendor source | Do not update working drivers by default |
| Realtek network/audio drivers | `windows-install-drivers` | Windows Update, OEM, or official vendor source | Do not update working drivers by default |
| Waves audio component | `windows-install-drivers` | OEM source | Do not update working drivers by default |

## Excluded Unless Explicitly Requested

- Microsoft built-in Windows apps.
- Visual Studio workloads/packages/components.
- VS Code/Cursor extensions when editor sync is available.
- Working drivers.
- Runtime/dependency packages that are normally installed by a parent app.
