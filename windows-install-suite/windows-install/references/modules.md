# Windows Installation Modules

This file defines the top-level module map for `windows-install`.

For single-app routing, also read [software-index.md](software-index.md). The software index is the authoritative fresh-conversation map from app names to modules and install sources.

Use these modules for both post-reinstall setup and later partial installs. A selected module may be run repeatedly; each child skill should verify current state, skip already-installed items when appropriate, and report repair/reinstall/update choices when needed.

## Modules

| Module | Skill | Scope | Default behavior |
| --- | --- | --- | --- |
| `basic` | `windows-install-basic` | Fonts, Typora, Obsidian, local/pinned basic apps, baseline utilities | Install or verify when selected |
| `work` | `windows-install-work` | Communication, email, and remote work tools | Install or verify when selected |
| `development` | `windows-install-development` | Developer CLIs, editors, Oh My Posh, npm globals, Visual Studio user extensions | Install or verify when selected after bootstrap verification |
| `drivers` | `windows-install-drivers` | OEM, firmware, and hardware driver audit | Audit-only by default; update only when missing/abnormal or explicitly approved |

## Child Skill Locations

Relative to this repository:

```text
windows-install-suite/windows-install-basic/SKILL.md
windows-install-suite/windows-install-work/SKILL.md
windows-install-suite/windows-install-development/SKILL.md
windows-install-suite/windows-install-drivers/SKILL.md
```

When installed into Codex, expose each child skill directory as an individual folder under `.codex/skills`, even though the git repository stores them under `windows-install-suite/`.

## Dependency Matrix

| Selected module | Requires | Preferred previous module | Notes |
| --- | --- | --- | --- |
| `basic` | None | None | Run first when selected |
| `work` | None | `basic` | Typora and Obsidian are in `basic`, not `work` |
| `development` | Codex, NVM for Windows, Node.js, npm | `basic` | Fonts from `basic` improve Oh My Posh rendering |
| `drivers` | None | App modules | Run audit after app installs unless hardware/network/display issues block setup |

## Global Exclusions

- Microsoft built-in Windows apps, unless the user explicitly asks for Store restore.
- Visual Studio workloads/packages/components, unless handled outside this skill through Visual Studio Installer or a user-provided `.vsconfig`.
- VS Code and Cursor extensions, unless the user explicitly requests manual extension installation.
- Working drivers, unless missing/abnormal devices or user-approved firmware/security fixes require action.

## Install Source Rules

1. Local installer or pinned package listed in a module reference wins.
2. Otherwise use online latest stable version.
3. Prefer `winget` with exact package ID.
4. Prefer silent machine-wide install for `winget` packages.
5. Prefer silent install for local installers when reliable silent arguments are known.
6. Allow local installers to run interactively when silent install is unsupported, silent install fails, or the user needs to choose paths or options.
7. Prefer custom location on the selected non-system drive when the installer supports it.
8. Treat the user-selected path in an interactive installer UI as authoritative.
9. Report installers that ignore custom install location or scope.
