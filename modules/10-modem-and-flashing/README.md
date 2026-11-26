# Module 10 — Global Modem Firmware & Fastboot Flash Scripts

- **Global Modem Firmware (`images/modemfirmware.img`, `141,152,256 B`):** Extracted from Xiaomi 15 Global Stock `OS4.0.0.11.XOCMIXM` (`SHA-256: b08a12a48ee8a84937ad4daa75ef7a33c34b12ef54f8ec46035cef75bfd641e`) and hosted on [**GitHub Releases (`v7.3.1-assets`)**](https://github.com/ampereforest/ColorOS-V6-Standalone-Mods/releases/tag/v7.3.1-assets) (`modemfirmware-dada-global-OS4.0.0.11.img`). Download automatically with `bash scripts/fetch_release_assets.sh`.
- **CN Hardware Variant Notice:** Users on Chinese hardware (`24129PN74C`) who want CN modem firmware should keep TUSB's original base V6 CN `images/modemfirmware.img` (`136,876,032 B`) or flash CN stock `modemfirmware.img` via `fastboot flash modemfirmware_ab modemfirmware.img`.
- **Flash Scripts:** Includes updated `linux-flash.sh` and `windows-flash.bat` matching our final `v7.3.1` fastboot package.
