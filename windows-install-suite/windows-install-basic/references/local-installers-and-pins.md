# Local Installers And Pinned Basic Apps

Programs listed here are exceptions to the "install latest online" rule.

Rules:

- Use local installers from `references/installer/` when a path is listed.
- Prefer silent install for local installers when reliable silent arguments are known.
- Use interactive installer UI only when silent install is unsupported, silent install fails, or the user explicitly wants to choose options/path manually.
- If the user chooses the install path in the installer UI, that selected path is authoritative.
- Use pinned versions only when a version is listed here.
- For every app not listed here, install the latest stable online version, preferably with `winget`.
- Put future manual installers under `references/installer/`.

## Local Installers

| App | Version | Installer | Default mode | Silent args | Architecture | Target path | Post-install |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Typora | 0.11.18 | `references/installer/Typora v0.11.18/typora-setup-x64-0.11.18.exe` | Silent first; interactive fallback if needed | `/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /DIR="[Drive]:\ProgramFiles\Typora"` | x64 | Silent target `[Drive]:\ProgramFiles\Typora`; interactive uses user-selected path | Detect actual path after install, then deny FullControl on `HKCU\SOFTWARE\Typora` for all listed principals |

## Pinned Online Packages

No pinned online basic packages yet.
