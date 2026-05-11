# Windows Driver Inventory

Snapshot source: this Dell machine on 2026-05-11.

This inventory is hardware-specific. Use it for auditing this machine or similar Dell hardware, not as a universal install list.

## OEM And Firmware

| Item | Observed version | Notes |
| --- | --- | --- |
| Dell SupportAssist | 5.0.2.2900 | OEM update and diagnostics utility |
| Dell SupportAssist for PCs MSIX | 5.0.1.0 | Store/MSIX companion app |
| Dell SupportAssist OS Recovery Plugin for Dell Update | 5.5.16.0 | Recovery/update plugin |
| Dell Core Services | 1.14.151.0 | OEM service component |
| Dell Connected Service Delivery | 1.1.1.0 | OEM service component |
| Dell Connected Service Delivery SubAgent | 1.1.1.0 | OEM service component |
| DellInstrumentation Device | 2.9.2.0 | Dell device instrumentation driver |
| System Firmware | 1.13.2 | Apply only from Dell/Windows Update |
| NVMe Firmware | 27.03.01.02 | Apply only from Dell/Windows Update |
| DELL_SE2726H monitor driver | 1.0.0.0 | Monitor INF |

## Intel Platform And Display

| Item | Observed version | Notes |
| --- | --- | --- |
| Intel Graphics Software | 26.8.2209.0 | MSIX app |
| Intel UHD Graphics 730 | 32.0.101.7084 | Display driver |
| Intel Graphics Software driver | 32.0.101.7084 | Display control stack |
| Intel Management Engine Interface #1 | 2546.8.9.0 | Chipset/platform |
| Intel Management Engine WMI Provider | 2544.8.3.0 | Chipset/platform |
| Intel Dynamic Tuning Technology | 9.1.10009.1745 | Thermal/power tuning |
| Intel Innovation Platform Framework | 2.3.20303.5058 | Platform framework components |
| Intel chipset root ports / SMBus / LPC / SPI | 10.1.37.7 / 10.1.45.9 | Chipset INF devices |
| Intel Wireless Manageability | 2543.98.178.0 | Wireless manageability |
| Intel GNA Scoring Accelerator | 3.5.0.1578 | Acceleration component |

## Network, Bluetooth, Audio, Storage

| Item | Observed version | Notes |
| --- | --- | --- |
| MediaTek Wi-Fi 6 MT7920 Wireless LAN Card | 3.5.0.1376 | Wi-Fi driver |
| MediaTek Bluetooth Adapter | 1.1045.0.566 | Bluetooth driver |
| Realtek PCIe GbE Family Controller | 1168.27.50.919 | Ethernet driver |
| Realtek Audio Universal Service | 1.0.813.0 | Audio service |
| Realtek Audio Effects Component | 13.1440.1501.444 | Audio effects |
| Realtek Asio Component | 1.0.13.1 | Audio component |
| Waves APO | 14.2.0.16723 | Audio processing component |
| Standard NVM Express Controller | 10.0.26100.7920 | Windows storage controller |
| Standard SATA AHCI Controller | 10.0.26100.7920 | Windows storage controller |

## Optional OEM Applications

| Item | Observed version | Notes |
| --- | --- | --- |
| Dell SupportAssist | 5.0.2.2900 | Optional unless using Dell update/diagnostics workflow |
| Intel Graphics Software | 26.8.2209.0 | Optional control app; display driver is the important part |

## Manual Checks

- Confirm the exact PC model before applying OEM packages.
- Confirm Device Manager has no unknown devices.
- Confirm Windows Update has no pending firmware or driver updates.
- Confirm Dell SupportAssist or OEM updater scan completes successfully if installed.
- Record skipped drivers explicitly when the current device is not present.
