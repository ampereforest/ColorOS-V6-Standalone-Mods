# Module 09 — Built-In Apps & UI

## Contents
- `launcher-17.5.4/`: Official ColorOS System Launcher `v17.5.4` (`170050004`, original Oplus V3 signature intact — do NOT re-sign).
- `osee-op15-global/`: OnePlus 15 Global OSee (`BaseOcrScanner.apk`, `OseeTileLauncher.apk`, `my_stock_applist_osee.patch`; `OcrScanner.apk` 114.5 MB is fetched via `scripts/fetch_release_assets.sh`).
- `openalive-wallpaper/`: Native `lib/arm64/*.so` libraries for `OpenAlive`, dynamic themed `openalive_more_drawable.xml`, and `wallpapers_classes5_openalive.smali.patch` integrating OpenAlive under *Settings → Home screen, Lock screen & style → More → Other → OpenAlive* (`OpenAlive.apk` 630.3 MB, English-translated & rootless, is fetched via `scripts/fetch_release_assets.sh`).
- `google-suite/`: `Gemini.apk` (5.4 MB) & `LatinImeGoogle.apk` (Gboard 76.2 MB); `VelvetCtS.apk` (305.4 MB) is fetched via `scripts/fetch_release_assets.sh`.
- `titanium-browser/`: Authentic ColorOS 17 Classic/Flux adaptive icons (`my_product/media/theme/uxicons/hdpi/io.github.jqssun.helium/*`), `morph_icons_whitelist.xml` patch, and `fetch_titanium_browser.sh` fetching the latest **pre-signed** APK directly from [`ampereforest/android-titanium-browser/releases/latest`](https://github.com/ampereforest/android-titanium-browser/releases/latest) (**DO NOT re-sign!**).
