# Visual Studio User Extensions

Snapshot source: user-level Visual Studio extension manifests on 2026-05-11.

Install the latest compatible version from the Visual Studio Marketplace unless a matching `.vsix` exists under `references/installer/`.

## Extensions To Restore

| Display name | Manifest ID | Observed version | Publisher |
| --- | --- | --- | --- |
| CSharpier | `83d6b6a0-9e25-4034-80f3-38445d8a8837` | 10.0.2 | CSharpier |
| File Icons | `3a7b4930-a5fb-46ec-a9b8-9610c8f953b8` | 2.8.244 | Mads Kristensen |
| IndentRainbow | `IndentRainbow.f05146ed-8025-4668-b7b1-8a74bd22b241` | 1.4.2 | Marcel Wagner |
| One Dark Pro 2026 | `Bayaraa.OneDarkPro2026` | 1.0.3 | Bayaraa |
| Open in Visual Studio Code | `e99dde0e-e023-410d-bc5d-3f76db71e3f0` | 1.4.63 | Mads Kristensen |
| Rainbow Braces | `RainbowBraces.1dff1bc5-a8e4-477b-9054-2b9ec6bb88d1` | 1.0.173 | Mads Kristensen |

## Install Procedure

1. Locate `VSIXInstaller.exe` under the installed Visual Studio path.
2. Search by display name and manifest ID on the official Visual Studio Marketplace.
3. Download the latest VSIX compatible with the installed Visual Studio major version.
4. Install quietly:

```powershell
$vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
$vsPath = & $vswhere -latest -products * -property installationPath
$vsixInstaller = Join-Path $vsPath 'Common7\IDE\VSIXInstaller.exe'
Start-Process -FilePath $vsixInstaller -ArgumentList '/quiet', '<path-to-extension.vsix>' -Wait
```

5. Restart Visual Studio and verify each extension appears under Extensions.

Do not install built-in Visual Studio components from `CommonExtensions` or `Common7\IDE\Extensions`; only restore user extensions listed above or explicitly requested by the user.
