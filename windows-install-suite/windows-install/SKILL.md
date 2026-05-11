---
name: windows-install
description: "Orchestrate Windows software installation, partial app installs, post-reinstall setup, audits, and follow-up maintenance by asking which apps or modules to run, resolving dependencies, choosing a global order, and delegating to windows-install-basic, windows-install-work, windows-install-development, and windows-install-drivers. Use for one-off app installs, installing selected modules, or setting up a Windows PC after reinstall."
---

# Windows Installation Orchestrator

## Purpose

Coordinate Windows install and maintenance skills as one top-level workflow.

This skill does not duplicate module inventories. It asks what to install, performs global preflight checks, resolves module dependencies, determines order, then loads and follows the selected child skills:

- `windows-install-basic`
- `windows-install-work`
- `windows-install-development`
- `windows-install-drivers`

## Required Module Map

Read these references before planning the run:

- [references/modules.md](references/modules.md): module map and dependency rules.
- [references/software-index.md](references/software-index.md): route specific software names to the correct module and install source.

Only read a child skill's `SKILL.md` and references after that module is selected or needed as a dependency.

In a fresh conversation, never rely on prior chat context for software names, package IDs, local installer paths, or post-install rules. Use `software-index.md` first when the user names a specific app.

## First User Questions

If the user did not already specify these answers, ask before installing anything substantial:

1. Which modules should run?
   - `basic`: fonts, Typora, Obsidian, baseline apps.
   - `work`: DingTalk, WeChat, Slack, MailMaster, Termius.
   - `development`: Git, CLIs, editors, Oh My Posh, npm globals, Visual Studio user extensions.
   - `drivers`: audit OEM/firmware/hardware drivers; update only missing or abnormal drivers.
   - `all`: run `basic`, `work`, `development`, plus `drivers` in audit-only mode.
   - A specific app name from `software-index.md`, for example `Typora`, `Slack`, `Windows Terminal`, or `Oh My Posh`.
2. Which install drive should be used for apps that support custom paths?
   - Default to the first non-system fixed drive, usually `D:`.
   - Use `[Drive]:\ProgramFiles` for x64 apps and `[Drive]:\ProgramFiles(x86)` for x86 apps.
3. What run mode should be used?
   - `plan`: produce the ordered plan only.
   - `install`: run installs after explicit confirmation.
   - `audit`: check current state without installing.
4. How should local installers run?
   - `silent-first`: use documented silent arguments, fall back to UI when needed.
   - `interactive`: show installer UI and let the user choose paths or options.
   - `silent-only`: use silent arguments and fail/skip instead of showing UI.

Default local installer mode is `silent-first`. In interactive fallback mode, the user-selected installer path is authoritative.

Ask about administrator elevation only when the selected modules require it. Font all-user install, machine-wide app install, Visual Studio extension install, WSL, drivers, and registry permission changes may require elevation.

## Single-App Requests

When the user asks to install one app, such as "install Typora" or "install Slack":

1. Look up the app in [references/software-index.md](references/software-index.md).
2. Select only the matching module unless a dependency is required.
3. Read the matching module `SKILL.md` and its relevant references.
4. Apply that module's local installer, pinned-version, latest-online, path, and post-install rules.
5. Report if the app is already installed and ask whether to skip, repair/reinstall, or update when that choice matters.
6. Report if the app is unlisted and ask whether to treat it as a latest-online install in the closest module.

## Global Preflight

Before any module or single-app work:

1. Confirm Windows and PowerShell context.
2. Confirm `winget` exists and the `winget` source is available.
3. Confirm network access if online latest-version installs are needed.
4. Resolve and create the target install directories:
   - `[Drive]:\ProgramFiles`
   - `[Drive]:\ProgramFiles(x86)`
5. Check whether local installers and pinned package files exist for selected modules or apps.
6. Record whether the current shell is elevated.
7. For `development`, verify user bootstrap:
   - Codex is installed.
   - NVM for Windows is installed.
   - Node.js and npm are available.

Do not start installation if a selected app or module's required local installer is missing. Report the missing file and stop or skip that app/module based on user instruction.

## Dependency Rules

- `basic` has no dependency and should run first when selected.
- `work` has no hard dependency, but run it after `basic` when both are selected.
- `development` depends on the user's manual bootstrap of Codex, NVM, and Node.js. If `basic` is selected, run `basic` before `development` so fonts are available before terminal prompt configuration.
- `drivers` is independent and optional. Run it after app modules by default, unless network, display, audio, or device issues block app installation.
- `drivers` defaults to audit-only inside an `all` run. Update drivers only when a missing/abnormal device is found or the user explicitly approves.
- Microsoft built-in Windows apps are excluded unless the user explicitly asks for Store restore.
- Visual Studio workloads/packages are excluded from orchestrated installs. Only Visual Studio user extensions are handled by `development`.
- VS Code and Cursor extensions should not be installed by the orchestrator; rely on editor sync unless the user explicitly requests manual extension installation.

## Default Order

Use this order after resolving selected modules. For a single-app request, run only its required preflight, dependency, and target module steps.

1. Preflight.
2. `windows-install-basic`, if selected.
3. `windows-install-work`, if selected.
4. `windows-install-development`, if selected.
5. `windows-install-drivers`, if selected or if a hardware problem blocks installation.
6. Final verification and summary.

If `development` is selected but `basic` is not selected, ask whether to install only the bundled fonts from `basic` before configuring Oh My Posh. If the user declines, continue and note that prompt glyphs may render incorrectly.

## Execution Protocol

For each selected module or app:

1. Read the module `SKILL.md`.
2. Read only the module references required by the current run.
3. Apply the module's local installer and pinned-version rules.
4. Use online latest stable versions for unpinned apps.
5. Prefer `winget` silent all-user install.
6. For local installers, use the selected local installer mode. Prefer silent install, but accept interactive fallback for packages that cannot be installed silently or when the user chooses the path manually.
7. Prefer the chosen non-system install drive where the installer supports it.
8. Capture installed, actual path, already present, skipped, failed, and manual items.

Never override a child skill's safety rule. If a module rule conflicts with this orchestrator, use the stricter rule and report the conflict.

## Confirmation Gate

Before running install commands, show a concise plan:

```text
Modules: basic, work, development
Mode: install
Install drive: D:
Local installers: silent-first
Order:
1. Preflight
2. windows-install-basic
3. windows-install-work
4. windows-install-development
Skipped:
- drivers: not selected
Requires admin: fonts, machine-wide installs, Typora registry ACL, Visual Studio extensions
```

Proceed only after the user confirms the plan.

## Final Report

Return a module-by-module summary:

- Selected modules and order.
- Install drive and run mode.
- Installed items.
- Actual install paths for local installers and packages that ignored requested paths.
- Already present items.
- Skipped items and reasons.
- Local installer or pinned-version items used.
- Online latest-version items installed.
- Admin-required items not completed.
- Reboot-required items.
- Manual follow-up steps, especially account sign-in, VS Code/Cursor sync, Visual Studio extension verification, and driver/OEM actions.
