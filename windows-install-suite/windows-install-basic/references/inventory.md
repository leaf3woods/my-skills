# Windows Basic Inventory

Snapshot source: this machine on 2026-05-11.

Use this inventory as a decision record, not as a forced version lock. Fixed/local versions live in [local-installers-and-pins.md](local-installers-and-pins.md). Everything else should use the latest stable online package, preferably through `winget`.

## Bundled Fonts

Install from `references/fonts`.

| Font file | Purpose |
| --- | --- |
| `3270NerdFont-Regular.ttf` | Terminal/editor Nerd Font |
| `FiraCode-Regular.ttf` | Coding font |
| `FiraCodeNerdFont-Regular.ttf` | Coding Nerd Font |
| `LXGWWenKai-Regular.ttf` | Chinese reading/writing font |

## Local Or Pinned Basic Apps

| Item | Version/source | Install decision |
| --- | --- | --- |
| Typora | `references/installer/Typora v0.11.18/typora-setup-x64-0.11.18.exe` | Install from local package; do not fetch latest unless the pin file is changed |

## Latest Online Basic Apps

Install these at latest stable version unless they appear in `local-installers-and-pins.md`.

| Item | Observed version | Package ID or source | Architecture | Target path |
| --- | --- | --- | --- | --- |
| Obsidian | 1.12.7 | `Obsidian.Obsidian` | x64 | `[Drive]:\ProgramFiles\Obsidian` |
| Clash Verge | 2.4.7 | `ClashVergeRev.ClashVergeRev` | x64 | `[Drive]:\ProgramFiles\ClashVerge` |
| ChatGPT Desktop | 1.2026.119.0 | Search `OpenAI.ChatGPT` / Store source if needed | x64/MSIX | Report if custom location is unsupported |
| Snipaste | 2.11.300.0 | Search with `winget search Snipaste` if requested | x64/MSIX | Report if custom location is unsupported |
| DevToys | 1.0.13.0 | Search with `winget search DevToys` if requested | x64/MSIX | Report if custom location is unsupported |

## Excluded From Basic

Do not independently install these from this skill:

- Microsoft built-in Windows apps such as Edge, Notepad, Paint, Photos, Calculator, Clock, Media Player, Microsoft Store, Get Help, Feedback Hub, Phone Link, To Do, Outlook for Windows, and bundled media extensions.
- Runtime/dependency packages that are normally installed by parent apps, such as WebView2, Visual C++ Redistributables, Windows App Runtime, Microsoft.UI.Xaml, and .NET Desktop Runtime.
- OEM drivers, firmware, chipset, graphics, Wi-Fi, Bluetooth, Ethernet, audio, storage, and monitor drivers.
- Development tools, CLIs, Visual Studio packages, VS Code extensions, and npm global packages.

## Manual Checks

- Confirm the target install drive before installing packages.
- Confirm `winget source list` includes `winget`; only use `msstore` when the user accepts Microsoft Store terms.
- Confirm Typora registry denial was applied only after Typora installation completed.
