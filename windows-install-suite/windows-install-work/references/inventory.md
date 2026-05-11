# Windows Work Inventory

Snapshot source: this machine on 2026-05-11.

Use this inventory as a decision record, not as a forced version lock. Fixed/local versions live in [local-installers-and-pins.md](local-installers-and-pins.md). Everything else should use the latest stable online package, preferably through `winget`.

## Latest Online Work Apps

| Item | Observed version | Package ID | Architecture | Target path |
| --- | --- | --- | --- | --- |
| DingTalk | 8.3.15-Release.260424004 | `Alibaba.DingTalk` | x64 | `[Drive]:\ProgramFiles\DingTalk` |
| WeChat | 4.1.8.107 | `Tencent.WeChat.Universal` | x64/MSIX | Report if custom location is unsupported |
| Slack | 4.49.89.0 | `SlackTechnologies.Slack` | x64 | `[Drive]:\ProgramFiles\Slack` |
| NetEase MailMaster | 5.5.7.1008 | `NetEase.MailMaster` | x64 | `[Drive]:\ProgramFiles\MailMaster` |
| Termius | 9.37.6 | `Termius.Termius` | x64 | `[Drive]:\ProgramFiles\Termius` |

## Moved To Basic

- Typora
- Obsidian

## Excluded Microsoft Built-Ins

Do not install these from this skill unless the user explicitly asks for a Microsoft Store restore:

- Outlook for Windows
- Microsoft To Do
- Phone Link
- OneDrive
- Sticky Notes
- Photos
- Quick Assist
- Power Automate Desktop

## Manual Account Restore

- DingTalk account and organization state
- WeChat account and chat backup, if needed
- Slack workspaces
- MailMaster accounts and signatures
- Termius account sync, hosts, identities, snippets, and known_hosts trust
