# Windows Development Inventory

Snapshot source: this machine on 2026-05-11.

Use this inventory as a decision record, not as a forced version lock. Fixed/local versions live in [local-installers-and-pins.md](local-installers-and-pins.md). Everything else should use the latest stable online package, preferably through `winget`.

## Bootstrap Prerequisites

The user expects to install these manually before this skill runs:

| Item | Observed state |
| --- | --- |
| NVM for Windows | 1.2.2 |
| Node.js via NVM | 24.15.0 active, 18.20.8 also installed |
| npm | 11.12.1 |
| Codex CLI | `@openai/codex@0.130.0` |

Observed paths:

```text
nvm     D:\nvm\nvm.exe
node    D:\nvm4w\nodejs\node.exe
npm     D:\nvm4w\nodejs\npm.ps1
codex   D:\nvm4w\nodejs\codex.ps1
```

## Latest Online Developer Apps

| Item | Observed version | Package ID | Architecture | Target path |
| --- | --- | --- | --- | --- |
| Git | 2.53.0.3 | `Git.Git` | x64 | `[Drive]:\ProgramFiles\Git` |
| GitHub CLI | 2.90.0 | `GitHub.cli` | x64 | `[Drive]:\ProgramFiles\GitHubCLI` |
| AWS CLI v2 | 2.34.33.0 | `Amazon.AWSCLI` | x64 | `[Drive]:\ProgramFiles\AWSCLI` |
| Miniconda3 managed Python | Resolve latest stable at install time | `Anaconda.Miniconda3` | x64 | `[Drive]:\ProgramFiles\Miniconda3` |
| PowerShell 7 | 7.6.1.0 | `Microsoft.PowerShell` | x64 | `[Drive]:\ProgramFiles\PowerShell7` |
| Windows Terminal | 1.24.10921.0 | `Microsoft.WindowsTerminal` | x64/MSIX | System-managed; configure after install |
| VS Code | 1.119.0 | `Microsoft.VisualStudioCode` | x64 | `[Drive]:\ProgramFiles\VSCode` |
| Cursor | 3.1.17 | `Anysphere.Cursor` | x64 | `[Drive]:\ProgramFiles\Cursor` |
| Bruno | 3.2.2 | `Bruno.Bruno` | x64 | `[Drive]:\ProgramFiles\Bruno` |
| DBeaver Community | 26.0.3 | `DBeaver.DBeaver.Community` | x64 | `[Drive]:\ProgramFiles\DBeaver` |
| WSL | 2.7.3.0 | `Microsoft.WSL` | x64 | System-managed |
| Oh My Posh | 29.13.1.0 | `JanDeDobbeleer.OhMyPosh` | x64 | `[Drive]:\ProgramFiles\OhMyPosh` |

## Windows Terminal Configuration

Read [windows-terminal.md](windows-terminal.md) after installing PowerShell, Windows Terminal, Codex, npm globals, and Oh My Posh.

Required defaults:

- Default terminal profile: PowerShell 7.
- Default terminal application: Windows Terminal, preferably through supported Windows/Terminal settings.
- Font: `FiraCode Nerd Font`.
- Background: acrylic enabled.
- Opacity: 66.
- Launch: centered.
- Profile order: PowerShell, Command Prompt, Codex, other AI CLI profiles, Linux distributions, remaining profiles.
- AI profiles: activate the selected Conda environment, defaulting to `base`, before launching each AI CLI.
- Icons: copy from `references/icons` when provided.

## Visual Studio Boundary

| Item | Observed version | Decision |
| --- | --- | --- |
| Visual Studio Community 2026 | 18.5.2 | Install only if explicitly needed; do not install workloads/packages from this skill |
| Visual Studio workloads/components | Many associated packages observed | Do not install independently |
| .NET SDK/runtime/targeting packs | Installed by Visual Studio / .NET tooling | Do not install independently unless explicitly missing |
| IIS Express, SQL LocalDB, Web Deploy, ODBC tools | Associated with Visual Studio / SQL tooling | Do not install independently unless explicitly needed |

Visual Studio instance observed:

```text
Visual Studio Community 2026
Version: 18.5.2
Path: D:\Program Files\Microsoft Visual Studio\18\Community
Channel: VisualStudio.18.Release
```

## npm Global Packages

Install latest versions unless pinned:

```text
@angular/cli
opencode-ai
```

Verify but do not reinstall by default:

```text
@openai/codex
corepack
npm
```

## VS Code And Cursor Extensions

VS Code extensions are expected to sync automatically. Treat the captured extension list as audit-only, not an install list.

Captured VS Code extensions:

```text
aaron-bond.better-comments@3.0.2
adpyke.vscode-sql-formatter@1.4.4
alefragnani.bookmarks@14.1.1
amazonwebservices.aws-toolkit-vscode@4.4.0
crispychicken.zhihu-fisher@0.6.6
cschlosser.doxdocgen@1.4.0
donjayamanne.githistory@0.6.20
dotjoshjohnson.xml@2.5.1
emilast.logfilehighlighter@3.5.1
esbenp.prettier-vscode@12.4.0
formulahendry.code-runner@0.12.2
george-alisson.html-preview-vscode@0.2.5
github.github-vscode-theme@6.3.5
github.vscode-github-actions@0.31.5
gruntfuggly.todo-tree@0.0.226
hediet.vscode-drawio@1.9.0
jeff-hykin.better-cpp-syntax@1.27.1
k--kato.docomment@1.0.2
mechatroner.rainbow-csv@3.24.1
ms-azuretools.vscode-docker@2.0.0
ms-ceintl.vscode-language-pack-zh-hans@1.118.2026050120
ms-dotnettools.csdevkit@3.10.14
ms-dotnettools.csharp@2.130.5
ms-dotnettools.vscode-dotnet-runtime@3.0.0
ms-edgedevtools.vscode-edge-devtools@2.1.10
ms-python.debugpy@2026.6.0
ms-python.isort@2026.4.0
ms-python.python@2026.4.0
ms-python.vscode-pylance@2026.2.1
ms-vscode-remote.remote-containers@0.459.0
ms-vscode-remote.remote-ssh@0.122.0
ms-vscode-remote.remote-ssh-edit@0.87.0
ms-vscode-remote.remote-wsl@0.104.3
ms-vscode.powershell@2025.4.0
ms-vscode.remote-explorer@0.5.0
oderwat.indent-rainbow@8.3.1
openai.chatgpt@26.506.31421
pkief.material-icon-theme@5.34.0
redhat.vscode-yaml@1.23.0
seyyedkhandon.firacode@2.2.2
streetsidesoftware.code-spell-checker@4.5.6
tomoki1207.pdf@1.2.2
vscode-icons-team.vscode-icons@12.18.0
vue.volar@3.2.8
yzhang.markdown-all-in-one@3.6.3
zhuangtongfa.material-theme@3.19.0
```

`cursor --list-extensions --show-versions` returned only a Node deprecation warning on this machine. Treat Cursor extension restore as sync/manual unless the user asks to mirror VS Code extensions.

## Python And Miniconda

Install Miniconda3 from `Anaconda.Miniconda3`.

Use Miniconda as the Python provider. Do not install standalone CPython, Microsoft Store Python, or a separate Conda distribution from this skill. Keep Miniconda base auto-activation disabled globally unless the user asks otherwise. Windows Terminal AI profiles should explicitly activate the selected Conda environment, defaulting to `base`, before launching each AI CLI.

Install `pyyaml` in the base environment because AI CLIs rely on Python YAML parsing. The Conda package name is `pyyaml`; the Python import is `yaml`. If AI CLI profiles use a non-base Conda environment, verify and install `pyyaml` in that environment too.

Validation should confirm Miniconda-managed Python:

```powershell
conda --version
where.exe conda
conda info
conda install -n base -y pyyaml
conda run -n base python --version
conda run -n base python -c "import yaml; print(yaml.__version__)"
```

If plain `python` resolves only to the WindowsApps alias, report it as an alias and continue using Miniconda through `conda run` or activated environments.

## Missing Or Manual Developer Items

| Item | Observed state | Action |
| --- | --- | --- |
| Docker CLI / Docker Desktop | Not found | Install only when container workflows require it |
| WSL distro | WSL installed, distro state not captured reliably | Verify with `wsl -l -v` and install a distro if needed |
| Git identity | Not captured | Configure per user preference |
| SSH keys and cloud credentials | Not captured | Restore manually and securely |
