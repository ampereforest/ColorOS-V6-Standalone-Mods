# Titanium Browser (ColorOS 17 Liquid Glass Edition)

- **Upstream Repository:** [`https://github.com/ampereforest/android-titanium-browser`](https://github.com/ampereforest/android-titanium-browser)
- **Latest Pre-Signed APK Releases:** [`https://github.com/ampereforest/android-titanium-browser/releases/latest`](https://github.com/ampereforest/android-titanium-browser/releases/latest)

## CRITICAL: Do NOT Patch or Re-Sign Titanium Browser!

`TitaniumBrowser.apk` (`io.github.jqssun.helium`) is intentionally **not bundled** inside `ColorOS-V6-Standalone-Mods` and **must never be re-signed** with your custom ROM keys in `signing/keys/`.

Why:
- Re-signing Titanium Browser with a different certificate causes signature mismatches (`INSTALL_FAILED_UPDATE_INCOMPATIBLE`) and blocks users from installing future standalone APK updates directly over the built-in ROM copy.
- Fetching the official pre-signed release APK directly from `ampereforest/android-titanium-browser/releases/latest` ensures every user can update Titanium Browser anytime without reflashing the ROM.

## Integration Steps

1. **Fetch the latest pre-signed APK into your unpacked ROM tree:**
   ```bash
   bash modules/09-apps-and-ui/titanium-browser/fetch_titanium_browser.sh \
     --out /path/to/unpacked_rom/product/app/TitaniumBrowser/TitaniumBrowser.apk
   ```
2. **Remove stock Via Browser:**
   ```bash
   rm -rf /path/to/unpacked_rom/system/my_stock/app/Via
   ```
3. **Install ColorOS 17 Classic & Flux adaptive icons (already bundled here):**
   ```bash
   cp -a modules/09-apps-and-ui/titanium-browser/my_product/. /path/to/unpacked_rom/system/my_product/
   patch -p1 -d /path/to/unpacked_rom/system < modules/09-apps-and-ui/titanium-browser/patches/my_stock_morph_icons_whitelist.patch
   ```
4. **Verify `signing/sign_rom_apks.sh` skips it:** `signing/sign_rom_apks.sh` explicitly excludes `TitaniumBrowser.apk` so its upstream signature remains 100% intact.
