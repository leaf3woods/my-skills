---
name: windows-install-drivers
description: "Audit or install missing/problematic Windows OEM drivers and firmware, including Dell/OEM utilities, BIOS/firmware, chipset, graphics, Wi-Fi, Bluetooth, Ethernet, audio, monitor, storage, or other device drivers. Use after reinstall or later when hardware issues appear. Do not update existing working drivers unless explicitly needed."
---

# Windows Driver Installation And Audit

## Purpose

Audit OEM, firmware, and hardware driver components when setting up Windows or diagnosing hardware issues.

This skill is optional. Many PCs do not need manual driver installation after Windows Update. Use it only when the user asks for driver checks, Device Manager has missing/problem devices, or a hardware function is not working.

## Required References

Read these files before auditing or installing driver-related components:

- [references/local-installers-and-pins.md](references/local-installers-and-pins.md)
- [references/inventory.md](references/inventory.md)

## Driver Policy

1. Unless a driver is clearly missing, broken, or tied to a user-approved firmware/security fix, do not update an existing working driver.
2. Do not treat this Dell snapshot as a universal install list.
3. Prefer Windows Update first, including optional driver updates when the user approves.
4. Prefer the exact OEM support page or OEM update tool for the machine model.
5. Use component-vendor drivers only when Windows Update and OEM sources are insufficient.
6. Ask before changing BIOS, firmware, storage controller, BitLocker, Secure Boot, virtualization, or encryption-related settings.
7. Do not install generic third-party driver updater software.

## Workflow

1. Identify manufacturer and model.
2. Check Device Manager/PnP state.
3. Record missing, non-OK, or generic fallback devices.
4. Install or update only the drivers needed to fix those findings.
5. Leave working drivers unchanged.
6. Report skipped driver categories explicitly.

## Audit Commands

```powershell
Get-CimInstance Win32_ComputerSystem |
  Select-Object Manufacturer, Model

Get-PnpDevice |
  Where-Object { $_.Status -ne 'OK' } |
  Select-Object Status, Class, FriendlyName, InstanceId

Get-CimInstance Win32_PnPSignedDriver |
  Select-Object DeviceName, Manufacturer, DriverVersion |
  Sort-Object Manufacturer, DeviceName
```

## Dell-Specific Path

For Dell machines only, install OEM tooling when the user wants Dell-managed updates:

```powershell
winget install --id Dell.SupportAssist -e `
  --silent --disable-interactivity `
  --accept-package-agreements --accept-source-agreements
```

Then use Dell SupportAssist or Dell Update to scan for the exact model. Apply only missing/problematic driver or firmware updates, unless the user explicitly approves a broader OEM update pass.

## Verification Report

Report:

- PC manufacturer and model.
- Unknown or non-OK devices.
- Drivers installed or updated, with reason.
- Working drivers intentionally left unchanged.
- Firmware/BIOS items requiring explicit approval.
- Items skipped because the current device is not present.
