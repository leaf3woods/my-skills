# Local Installers And Pinned Developer Apps

Programs listed here are exceptions to the "install latest online" rule.

Rules:

- Use local installers from `references/installer/` when a path is listed.
- Use pinned versions only when a version is listed here.
- For every app not listed here, install the latest stable online version, preferably with `winget`.
- Put future manual installers, VSIX files, and `.vsconfig` files under `references/installer/`.

## Local Installers

No local developer installers yet.

## Pinned Online Packages

No pinned online developer packages yet.

## Explicit Non-Install Items

| Item | Rule |
| --- | --- |
| Visual Studio workloads/packages/components | Do not install from this skill |
| VS Code extensions | Do not install by default; rely on Settings Sync |
| Cursor extensions | Do not install by default unless the user asks to mirror VS Code |
| Standalone CPython / `Python.Python.3.x` | Do not install from this skill; Python is managed by Miniconda |
| Full Anaconda or separate Conda distribution | Do not install; use Miniconda3 only |
