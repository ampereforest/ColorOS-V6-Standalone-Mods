# ColorOS 17 V6 Standalone Mods (`MOD@tarosaiya` `v7.3.1`) — Xiaomi 15 (`dada`)

The complete, self-contained, 100% rootless standalone mod suite, source code, verified unified `.patch` files, offset-verified AArch64 ELF patchers, pre-made custom binaries, non-V6 compatibility assets, and custom platform signing pipeline transforming **base ColorOS 17 V6 CN (`PLZ110` by TUSB_5834@Coolapk)** into **`ColorOS 17 V6 MOD@tarosaiya` (`v7.3.1`)** for **Xiaomi 15 (`dada`, `24129PN74G`, Snapdragon 8 Elite / SM8750)**.

Zero external ROM dumps required. Zero root, Magisk, KernelSU, or LSPosed required at runtime.

---

## Table of Contents

1. [Architecture & Companion Upstream Repositories](#1-architecture--companion-upstream-repositories)
2. [Modular Repository Layout & GitHub Release Assets](#2-modular-repository-layout--github-release-assets)
3. [Step-by-Step Build & Integration Guide](#3-step-by-step-build--integration-guide)
4. [Custom Platform & App Signing (`signing/`)](#4-custom-platform--app-signing-signing)
5. [Titanium Browser Integration (Do NOT Re-Sign!)](#5-titanium-browser-integration-do-not-re-sign)
6. [Complete Categorized Changelog (Base V6 → `v7.3.1`)](#6-complete-categorized-changelog-base-v6--v731)
   - [6.1 Camera & Gallery (Leica MiuiCamera, Gallery AI Editor & WIP OPPO Camera)](#61-camera--gallery-leica-miuicamera-gallery-ai-editor--wip-oppo-camera)
   - [6.2 Display, 1–120 Hz Hardware LTPO, 3200-Nit HDR, Color Mode & GPU/ANGLE](#62-display-1120-hz-hardware-ltpo-3200-nit-hdr-color-mode--gpuangle)
   - [6.3 Thermal, Idle Power, Smoothness, 5G/Tethering & Zero-Delay Rootless FCM](#63-thermal-idle-power-smoothness-5gtethering--zero-delay-rootless-fcm)
   - [6.4 Connectivity, eSIM, Modem, Charging, Bypass Charging & OTG](#64-connectivity-esim-modem-charging-bypass-charging--otg)
   - [6.5 Audio, Adaptive Multi-Texture O-Haptics, Sensors & Touch](#65-audio-adaptive-multi-texture-o-haptics-sensors--touch)
   - [6.6 System UI, Lock Screen, Settings, Developer Options & Apps](#66-system-ui-lock-screen-settings-developer-options--apps)
   - [6.7 Root Integrity, Duck Detector `[Clear]`, Zero `oplusex` Mounts & Stability](#67-root-integrity-duck-detector-clear-zero-oplusex-mounts--stability)
7. [Post-Setup Thermal Notice](#7-post-setup-thermal-notice)
8. [Optional Companion Kernel (`wild-trsy` `r24`)](#8-optional-companion-kernel-wild-trsy-r24)
9. [Credits](#9-credits)

---

## 1. Architecture & Companion Upstream Repositories

Every modification in this repository follows two strict rules:
- **Pre-made / custom-compiled binaries & non-V6 assets** (daemons, Nyako hooks, Adreno GPU drivers, URCC HAL, OplusCamera SDK/configs/libs, statically baked `opex` payloads, OSee, Gboard, Gemini, Launcher `v17.5.4`, etc.) are included directly (or hosted as GitHub Release assets if >100 MB) — never as binary `.patch` files.
- **Modifications to original Base V6 ROM files** (XMLs, `.rc` init scripts, `build.prop`, SELinux CIL/contexts, decompiled smali for `SystemUI`/`Settings`/`TeleService`/`Wallpapers`/`services.jar`/`oplus-services.jar`/`telephony-common`/`ims-ext-common`/`fod-bridge`, and ELF instruction patches) are provided as clean, reproducible `.patch` files and offset-verified Python patchers.

For detailed partition-by-partition verification across all 7 `super.img` partitions, see [`CHANGELOG-FULL-AUDIT.md`](CHANGELOG-FULL-AUDIT.md).

### Mirrored & Linked Companion Repositories

This repository mirrors the finalized `v7.3.1` snapshots of our core upstream repositories into `modules/` for one-stop integration while linking directly back to each dedicated upstream repository:

| Upstream Repository | Included In | Scope |
| :--- | :--- | :--- |
| [**`ampereforest/coloros_heat_optimization_findings`**](https://github.com/ampereforest/coloros_heat_optimization_findings) | [`modules/01-thermal-heat-ltpo-fcm/`](modules/01-thermal-heat-ltpo-fcm/) | Full `v7.3.1` thermal, idle power (`0.79%` screen-off CPU), WALT, LTPO `overlay.so` v4.1, zero-`execmem` + 17-scope `libnyako_core.so`, rootless FCM hooks, `QtiImsExtConnector` bind-storm fix, `swappiness=60`, prebuilt binaries, and KMI-safe GKI tweaks |
| [**`ampereforest/dada_esim_compat`**](https://github.com/ampereforest/dada_esim_compat) | [`modules/02-esim-compat/`](modules/02-esim-compat/) | Persistent eSIM ↔ pSIM2 hardware routing (`n3-route-v2`), `n3-runtime-v2` with `linkToDeath()` recovery, `OpenEUICC` bridge, native ColorOS 17 COUI `DadaEsimUI`, `TeleService` entry, and `PackageManagerServiceUtils` signer compat |
| [**`ampereforest/xiaomi-dada-miuicamera-port-fix`**](https://github.com/ampereforest/xiaomi-dada-miuicamera-port-fix) | [`modules/03-camera-leica-miuicamera/`](modules/03-camera-leica-miuicamera/) | `libdada_camfix.so`, `libdada_rtfix.so`, 50MP/Pro RAW/Ultra RAW DNG fixes, Portrait depth tuning, top-menu crash fix, and ColorOS 17 Classic/Flux camera icon port |
| [**`ampereforest/dada_coloros_cam_port`**](https://github.com/ampereforest/dada_coloros_cam_port) | [`modules/04-camera-oplus-experimental/`](modules/04-camera-oplus-experimental/) | WIP experimental OPPO Camera (`PMX110` `v7.013.40`, default OFF) smali/SDK patches + all 26 `odm` configs & 78 `product/lib64` libraries |
| [**`ampereforest/android-titanium-browser`**](https://github.com/ampereforest/android-titanium-browser) | [`modules/09-apps-and-ui/titanium-browser/`](modules/09-apps-and-ui/titanium-browser/) | ColorOS 17 Liquid Glass Titanium Browser — **fetched pre-signed directly from Releases (never re-signed!)** |
| [**`ampereforest/GKI_KernelSU_SUSFS`** (`r24`)](https://github.com/ampereforest/GKI_KernelSU_SUSFS/releases/tag/r24) | Optional Kernel | Companion `6.6.118-android15-wild-trsy` GKI kernel with KernelSU, SUSFS, DroidSpaces & power-efficiency config |
| [**`ampereforest/dada_hdr_compat_for_ported_rom`**](https://github.com/ampereforest/dada_hdr_compat_for_ported_rom) | [`modules/05-display-hdr-color-and-haptics/`](modules/05-display-hdr-color-and-haptics/) | 3200-nit HDR panel spline, `HDR Level` UI, and Inline SDR Saturation architecture (upgraded to `0.000%` idle C++ `hdrpeakd`) |
| [**`ampereforest/disable_lmkd_coloros`**](https://github.com/ampereforest/disable_lmkd_coloros) | [`modules/01-thermal-heat-ltpo-fcm/`](modules/01-thermal-heat-ltpo-fcm/) & [`modules/08-systemui-settings-and-stability/`](modules/08-systemui-settings-and-stability/) | Developer Options `Disable memory killer` (`0–500 MB` floor, upgraded to native C `cos17_memkiller_ctl`) |
| [**`ampereforest/android-adaptive-haptics`**](https://github.com/ampereforest/android-adaptive-haptics) | [`modules/05-display-hdr-color-and-haptics/`](modules/05-display-hdr-color-and-haptics/) | Multi-texture adaptive O-Haptics architecture, 24 kHz RTP onset audit, and RichTap HE 1.0/2.0 proxy |
| [**`ampereforest/coui-skill`**](https://github.com/ampereforest/coui-skill) | Reference | ColorOS 17 (COUI) UI/UX design tokens, Liquid Glass blur, squircle cards, and RK4 overscroll used across `DadaEsimUI` & `DadaAngleUI` |
| [**`ampereforest/coloros17-md3-systemui-hook`**](https://github.com/ampereforest/coloros17-md3-systemui-hook) | Optional Add-on | Optional Zygisk ARM64 hook for Material You QS slider track blur & dark-mode scrim tint |

---

## 2. Modular Repository Layout & GitHub Release Assets

```text
ColorOS-V6-Standalone-Mods/
├── README.md
├── CHANGELOG-FULL-AUDIT.md
├── LICENSE
├── signing/                                   # Local key generation, framework cert stamping & APK re-signer
│   ├── SIGNING-GUIDE.md
│   ├── generate_keys.sh
│   ├── render_framework_signer.py
│   ├── sign_rom_apks.sh
│   └── keys/.gitkeep                          # Gitignored — your local private keys stay strictly local
├── scripts/
│   ├── fetch_release_assets.sh                # Downloads & SHA-256 verifies all 5 >100 MB GitHub Release assets
│   ├── RELEASE_ASSETS.sha256
│   └── apply_all_patches.sh                   # Applies patches, installs prebuilts/assets & runs ELF patchers
└── modules/
    ├── 01-thermal-heat-ltpo-fcm/              # Full mirror of coloros_heat_optimization_findings (v7.3.1)
    ├── 02-esim-compat/                        # Full mirror of dada_esim_compat + prebuilt n3-route-v2/OpenEUICC/DadaEsimUI
    ├── 03-camera-leica-miuicamera/            # MiuiCamera 50MP/RAW/Ultra RAW/Portrait/Menu fixes + Classic/Flux icons + camfix/rtfix shims
    ├── 04-camera-oplus-experimental/          # Experimental OPPO Camera (PMX110) SDK JARs, 26 odm configs, 78 product/lib64 libs & patches
    ├── 05-display-hdr-color-and-haptics/      # 3200-nit HDR, Inline SDR Saturation, OplusServices EDR/VRR/Desktop, xmchgshim (OTG/Limit/Bypass), Haptics binary patcher
    ├── 06-gpu-adreno-angle-and-urcc/          # Adreno EGL v842.52 / Vulkan 1.4 512.842.52 (42 libs), ANGLE (DadaAngleUI src + APK), PLZ110 URCC/UAH HAL
    ├── 07-gallery-editor-and-opex/            # Gallery Editor 5-lib SIGSEGV patcher + 26 statically baked /system_ext/opex payloads
    ├── 08-systemui-settings-and-stability/    # PIN instant unlock + no arrow, Circle to Search, DevOpts, Disable Cutout, Bluetooth/Contacts crash fixes, 4-icon dock
    ├── 09-apps-and-ui/                        # OplusLauncher v17.5.4, OSee, OpenAlive libs & Wallpapers patch, Gemini & Gboard, Titanium Browser fetch script + uxicons
    └── 10-modem-and-flashing/                 # Global OS4.0.0.11 modem firmware instructions + Linux/Windows fastboot flash scripts
```

### Self-Contained >100 MB GitHub Release Assets (`v7.3.1-assets`)

Every file under 100 MB is tracked directly in git. To respect GitHub's 100 MB single-file git limit **without relying on any external third-party file host**, the 5 non-V6 files larger than 100 MB are hosted directly on [**GitHub Releases (`v7.3.1-assets`)**](https://github.com/ampereforest/ColorOS-V6-Standalone-Mods/releases/tag/v7.3.1-assets) and downloaded + SHA-256 verified automatically via `scripts/fetch_release_assets.sh`:

| Release Asset | Size | Source ROM / Origin | Target ROM Path |
| :--- | :---: | :--- | :--- |
| `OpenAlive-v0.4.43-en-rootless.apk` | `630.31 MB` | `Maga-King/OpenAlive` (376 CN strings translated to English, rootless, `CATEGORY_LAUNCHER` hidden) | `/product/app/OpenAlive/OpenAlive.apk` |
| `VelvetCtS-17.46.15-arm64.apk` | `305.43 MB` | Xiaomi 15 Global `OS4.0.0.11.XOCMIXM` (Google App for Circle to Search) | `/product/priv-app/VelvetCtS/VelvetCtS.apk` |
| `OplusCamera-7.013.40-dada-wip.apk` | `173.78 MB` | OPPO `PMX110_17.0.0.116(CN01)` + `dada_coloros_cam_port` patches | `/my_product/app/OplusCamera/OplusCamera.apk` |
| `modemfirmware-dada-global-OS4.0.0.11.img` | `134.61 MB` | Xiaomi 15 Global Stock `OS4.0.0.11.XOCMIXM` | `images/modemfirmware.img` |
| `OcrScanner-17.2.22-OP15-Global.apk` | `114.46 MB` | OnePlus 15 Global `CPH2747` (OSee document & AI scanner) | `/my_stock/del-app/OcrScanner/OcrScanner.apk` |

*(Titanium Browser is fetched directly from [`ampereforest/android-titanium-browser/releases/latest`](https://github.com/ampereforest/android-titanium-browser/releases/latest) — see [Section 5](#5-titanium-browser-integration-do-not-re-sign).)*

---

## 3. Step-by-Step Build & Integration Guide

### Prerequisites
- Original base ROM: **`Xiaomi15_ColorOS17_V6.zip`** (by `TUSB_5834@Coolapk`), unpacked into `odm/`, `product/`, `system/`, `system_ext/`, `vendor/` trees (plus `images/`).
- Host tools: `python3`, `patch`, `openssl`, `keytool`, `curl`, `baksmali`/`smali`, `apktool`, Android SDK Build-Tools (`zipalign`, `apksigner`), `mkfs.erofs`, `lpmake`, `secilc`.

### Integration Workflow

```bash
# 1. Clone this repository
git clone https://github.com/ampereforest/ColorOS-V6-Standalone-Mods.git
cd ColorOS-V6-Standalone-Mods

# 2. Generate your own local platform, media, shared, releasekey & eSIM signing certificates
bash signing/generate_keys.sh

# 3. Automatically stamp your generated certificate SHA-256 digests into
#    services-platform-signer-compat.patch and eSIM CallerPolicy.java
python3 signing/render_framework_signer.py

# 4. Download & SHA-256 verify all 5 >100 MB GitHub Release assets + apply all
#    text/XML/RC/SELinux patches, pre-made binaries, non-V6 assets & ELF binary patchers
bash scripts/apply_all_patches.sh --rom-root /path/to/unpacked_rom

# 5. Merge SELinux CIL additions into plat_sepolicy.cil & plat_sepolicy_debug.cil,
#    validate with `secilc -N` (NEW_PAIRS=0), and update plat_sepolicy_and_mapping*.sha256:
#      - modules/01-thermal-heat-ltpo-fcm/patches/03-telephony-wifi-rps/system_sepolicy_cos17_snippet.cil
#      - modules/02-esim-compat/config/selinux/n3-route-v2.cil

# 6. Build n3-runtime-v2.jar with your stamped CallerPolicy.java & install to /system/framework/n3-runtime-v2.jar
python3 modules/02-esim-compat/scripts/build_java.py

# 7. Apply smali patches (disassemble via baksmali, apply .patch, reassemble via smali, purge stale oat/):
#      - product/framework/ims-ext-common.jar   <- modules/01-.../product_ims_ext_common_qti_connector.smali.patch
#      - system/framework/services.jar          <- Module 02 (N3 + SELinuxMMAC + signer compat),
#                                                  Module 05 (HDR/Saturation), Module 08 (ContextualSearch + Cutout)
#      - system/framework/oplus-services.jar    <- Module 05 (EDR 4.9f + VRR/Desktop Mode)
#      - system/framework/telephony-common.jar & system_ext/framework/oplus-telephony-common.jar <- Module 02 (R1/R2/R3)
#      - system_ext/priv-app/SystemUI/SystemUI.apk <- Module 08 (PIN instant unlock + Circle to Search)
#      - system_ext/priv-app/Settings/Settings.apk <- Module 08 (HDR/Saturation/DevOpts/CtS/QuickUnlock) + Module 05 hdr_level_banner.png
#      - system_ext/priv-app/TeleService/TeleService.apk <- Module 02 (Manage eSIM entry)
#      - my_stock/priv-app/Wallpapers/Wallpapers.apk     <- Module 09 (OpenAlive entry + openalive_more_drawable.xml)
#      - product/priv-app/MiuiCamera/MiuiCamera.apk      <- Module 03 (DNG thumb, top-menu crash fix, Classic/Flux adaptive icon)
#    And inject DT_NEEDED for MiuiCamera shims:
#      python3 modules/03-camera-leica-miuicamera/native_hooks/patch_elf_needed.py ...

# 8. Align & sign all modified APKs automatically using your local signing/keys/
#    (explicitly SKIPS TitaniumBrowser.apk and untouched OEM/Google APKs!)
bash signing/sign_rom_apks.sh --rom-root /path/to/unpacked_rom

# 9. Fetch the latest PRE-SIGNED Titanium Browser directly from upstream Releases (DO NOT re-sign!)
bash modules/09-apps-and-ui/titanium-browser/fetch_titanium_browser.sh \
  --out /path/to/unpacked_rom/product/app/TitaniumBrowser/TitaniumBrowser.apk

# 10. Repack EROFS partitions (-Ededupe) with synced fs_config/file_contexts, assemble super.img
#     via lpmake, and flash alongside Global (or CN) images/modemfirmware.img using modules/10-modem-and-flashing/!
```

---

## 4. Custom Platform & App Signing (`signing/`)

Full instructions live in [**`signing/SIGNING-GUIDE.md`**](signing/SIGNING-GUIDE.md).

- **`signing/generate_keys.sh`** creates RSA-4096 keys (`platform`, `media`, `shared`, `releasekey`, and `esim-release`) in `.pk8`, `.x509.pem`, and `.p12` formats inside `signing/keys/` (strictly `.gitignore`d — never commit private keys!).
- **`signing/render_framework_signer.py`** automatically extracts the SHA-256 digests from `signing/keys/platform.x509.pem` & `signing/keys/esim-release.x509.pem` and updates:
  - `PackageManagerServiceUtils.isDadaPlatformCompat()` & `isDadaSigner()` (`services-platform-signer-compat.patch`) so your re-signed `SystemUI.apk`, `Settings.apk`, and `TeleService.apk` interoperate seamlessly with Oplus platform-signed `framework-res.apk` and shared UIDs (`android.uid.phone` / `android.uid.system`).
  - `CallerPolicy.java` (`CERT_SHA256`) for the eSIM `IDadaEsimBridge` binder contract.
- **`signing/sign_rom_apks.sh`** automatically reads `signing/keys/` to `zipalign -P 16 -f 4` and v1+v2+v3 `apksigner sign` all modified system APKs (`SystemUI`, `Settings`, `TeleService`, `Wallpapers`, `MiuiCamera`, `OplusCamera`, `aon.frameworkres.overlay.product.apk`, `DadaAngleUI`, `DadaEsimUI`, `OpenEUICC`).

---

## 5. Titanium Browser Integration (Do NOT Re-Sign!)

- **Upstream Repository:** [`https://github.com/ampereforest/android-titanium-browser`](https://github.com/ampereforest/android-titanium-browser)
- **Latest Pre-Signed Releases:** [`https://github.com/ampereforest/android-titanium-browser/releases/latest`](https://github.com/ampereforest/android-titanium-browser/releases/latest)

> **IMPORTANT:** **Do NOT patch or re-sign `TitaniumBrowser.apk`** with your custom keys in `signing/keys/`. Re-signing causes signature conflicts and prevents standalone APK updates without reflashing the ROM.

Instead, run our fetch script to pull the latest official pre-signed APK directly from GitHub Releases:

```bash
bash modules/09-apps-and-ui/titanium-browser/fetch_titanium_browser.sh \
  --out /path/to/unpacked_rom/product/app/TitaniumBrowser/TitaniumBrowser.apk
```

Only the ROM-side ColorOS 17 Classic/Flux adaptive icon assets (`my_product/media/theme/uxicons/hdpi/io.github.jqssun.helium/*`), `morph_icons_whitelist.xml` patch, and 4-icon default dock workspace patch are stored in this repository.

---

## 6. Complete Categorized Changelog (Base V6 → `v7.3.1`)

Covers every single item from the official `v7.3.1` release changelog **plus every undocumented / under-the-hood improvement** verified by our full 7-partition base-vs-final audit.

### 6.1 Camera & Gallery (Leica MiuiCamera, Gallery AI Editor & WIP OPPO Camera)
- **MiuiCamera 50MP, Pro 50MP RAW & Ultra RAW Fixed:** Added native shims `libdada_camfix.so` (`DT_NEEDED` in `libcameraservice.so`) and `libdada_rtfix.so` (`DT_NEEDED` in `libandroid_runtime.so`) fixing 50MP BLOB `4.4 MB` truncation (`xiaomi.scaler.availableStreamConfigurations`) and full-resolution `8192×6144` Pro RAW / 12MP Ultra RAW DNG capture, plus `MiuiCamera.apk` `"Xiaomi Ultra RAW"` DNG thumbnail preview patch (`n7/x.smali`).
- **Portrait Mode Bokeh & Non-Human Object Detection:** Tuned `odm/etc/camera/dualcam_{bokeh,depth,predepth}_params_pro.json` and persisted `persist.vendor.camera.mialgo.{capdepth,capbokeh}.debuglitemode=0` in `odm/etc/build.prop` for reliable depth separation across indoor lighting and non-human subjects.
- **MiuiCamera Top-Bar Menu Crash Fixed:** Patched `LSf/a;->b` fallback to `Resources.getDrawable()` fixing `FileNotFoundException: obfu_res/.../ic_west_coast_princess.webp` crashes on top-chevron / swipe-down menus.
- **Native ColorOS 17 Camera Adaptive Icons:** Replaced MiuiCamera's stock icon with calibrated ColorOS 17 Classic & Flux (monochrome wallpaper-matched) icons ported from `PLZ110`.
- **ColorOS Gallery Editor (`PhotoEditorActivity`) Native `SIGSEGV` Fix & Full AI Editor Support:**
  - Zeroed uninitialized `.data` `mIs*` flags across both `libMsEffectSdk.so` copies (`my_product/lib64/` 14 flags, `product/lib64/` 15 flags) and NOP'd two unchecked `blr x8` calls in `APSClient_createClient` across all 3 `libAPSClient-cmd-jni*.so` libraries (`product/`, `my_product/`, `system_ext/`) — completely eliminating instant crashes when tapping **Edit**.
  - Kept `com.oplus.aiunit` and `com.oplus.deepthinker` unblocked on-demand so all 8 ColorOS 17 AI Editor tools (*Photo Agent, AI Recompose, AI Eraser, AI Portrait Glow, AI Perfect Shot, AI Detail Boost, AI Unblur,* and *AI Reflection Eraser*) run cleanly and return to `0.0%` background CPU on exit.
- **Experimental Ported OPPO Camera (`com.oplus.camera` v7.013.40, Default OFF):** Bundled from OPPO `PMX110` with `dada_coloros_cam_port` SDK (`DadaJpegSaver`, `DadaZoomAnimator`), 26 `odm/etc/camera/config/*` configs, and 78 `product/lib64` libraries; toggled **OFF** by default via *Developer Options → Enable Oplus Camera*. Photo and Video modes work across all lenses and resolutions with proper lens-switching animations; Portrait, Pro, and full OPPO multi-frame HDR remain WIP while Leica MiuiCamera remains your primary fully working camera.

### 6.2 Display, 1–120 Hz Hardware LTPO, 3200-Nit HDR, Color Mode & GPU/ANGLE
- **True 1–120 Hz Dynamic Hardware LTPO + Soft-Reboot Immunity:**
  - Replaced polling `overlay.so` (`2.0 MB`) with zero-polling `15.6 KB` C++ `overlay.so` v4.1 (`0.06%` SF CPU at 1 Hz, `kIdle10Ms=300ms`, real measured Hz) + Trampoline 3 pre-guard on `RefreshRateSelector::setPolicy` preventing deterministic `SIGABRT` soft reboots across Fullscreen AOD / Doze / 60 Hz transitions.
  - Upgraded `libNyako_hook_ltpofix.so` v8.1 to `pipe2()` event bridge + post-Doze `+120/320ms` wake resync (eliminating `GROUP_IDLE_1` 60 Hz wake trap) + `oplus_vrr_config.json`, `refresh_rate_config.xml`, and `OplusRefreshRatePolicyImpl` IME/VRR fixes.
  - Disabled global UniRender switch (`sys_global_uni_render_list.xml` `func_switch=0`, `composeuni.enable=0`) for fluid 120 Hz Recents and Home animations.
- **3200-Nit Ultra HDR Peak Brightness, `HDR Level` UI & Inline SDR Saturation Slider:**
  - Replaced `10.8%` CPU shell `hdrpeak.sh` with `0.000%` idle event-driven C++ `vendor/bin/hdrpeakd` (`IHdrLayerInfoListener` + `IDisplayFeature` AIDL + futex property wait; legacy `hdrblfollow.rc` disabled).
  - Updated panel spline (`vendor/etc/displayconfig/display_id_4630946682710401939.xml`), `com.oplus.oplus-feature.xml`, `displayfeature.default.so` (5-insn patch), `libsdmextension.so` (1-insn patch), `oplus-services.jar` (`4.9f` HDR headroom & EDR dimming), and `services.jar` (`InlineSdrSaturationController`).
  - Added dedicated **`HDR Level`** sub-screen (*Settings → Display & brightness*) with peak luminance scaling + non-HDR boost and an **`0..200` Inline SDR Saturation slider** inside *Screen color mode*.
- **Fixed Sudden Screen Saturation Jumps:** Injected in-process AArch64 RenderIntent translation (`301→257`, `303→258`, `307→256`) into `/system/bin/surfaceflinger` and patched `/odm/bin/hw/oplus-color-mode-sync` to sleep infinitely on kernel futex (`8,854 → 0` jiffies).
- **Under-Display CWB Throttling (`ro.vendor.cwb.timeout=1000`):** Cuts continuous video/scroll CWB framebuffer captures by `-79.5%` (`39 → 8`) while preserving Xiaomi 15's under-display BOLED `TCS3720` ALS/Auto-Brightness & ultrasonic proximity accuracy (`persist.vendor.debug.cwb.disable=false` dirty-flash guard + `<LightSensorAlwaysOnSupport>0</LightSensorAlwaysOnSupport>`).
- **Updated Adreno GPU Drivers (`EGL v842.52` / `Vulkan 1.4 512.842.52`):** Full 42-library Adreno `V842.52` + `hexlp-V2-ndk.so` driver update, `android.hardware.vulkan.version-1_4.xml`, and updated OpenGL ES / Vulkan dEQP level XMLs (`2025-03-01`).
- **ANGLE Graphics Driver & Native COUI Selector (`DadaAngleUI`):** Added *Developer Options → ANGLE graphics driver* allowing per-app Vulkan rendering (including an option to show system apps) over system `libEGL_angle.so`.
- **ColorOS 17 `PLZ110` URCC / UAH HAL Fix:** Updated 5 `odm` URCC/UAH binaries/libraries + `odm_{file,service}_contexts` (`hal_urcc_service`) so UAH/URCC scheduler hints bind cleanly instead of returning `null`.

### 6.3 Thermal, Idle Power, Smoothness, 5G/Tethering & Zero-Delay Rootless FCM
- **`QtiImsExtConnector` Infinite Bind-Storm Eliminated (`v7.3.1`):** Guarded `product/framework/ims-ext-common.jar` with `PackageManager.resolveService(intent, 0) == null` early return (and removed stale `oat/`), dropping `11,734` failed bind hits/34m (`6–10` Binder IPCs/s) to **`0`** and slashing pure non-root screen-off `Asleep` CPU from **`3.1–3.3% → 0.79%` (`-75%`)** while keeping `imsdaemon` VoLTE/VoNR/5G EN-DC intact.
- **`vm.swappiness=60` & `WatermarkScale=20` (`v7.3.1`):** Fixed `cos17_daemons.rc` (`disable_mem_killer=0` now writes `swappiness=60` instead of `100`) and `init.kernel.post_boot-memory.sh` (`WatermarkScale=65 → 20`), eliminating `kswapd0` reclaim thrashing (`0` settled ticks).
- **Zero-Clock-Cap Thermal & 120 Hz WALT Tuning (`init.cos17_dada_perf.rc`):**
  - Switched `mi_thermald` from unthrottled `sconfig=50` to stock balanced `sconfig=0` (`GL-NORMAL`, full `3.53/4.32 GHz` CPU & `1,100 MHz` GPU uncapped).
  - Neutralized `<PerfBreak/>` in both `odm/etc/thermalbreakboostconfig.xml` and `vendor/etc/perf/thermalbreakboostconfig.xml`; stripped scroll `SCHEDBOOST=2` (`0x40C00000`) and the 5s `680 MHz` GPU floor from `vendor/etc/perf/perfboostsconfig.xml`; enabled `ro.vendor.perf.sagt=true`; restored Xiaomi 15's `thermallevel_to_fps.xml` curve and `thermal_zone57` sensor path.
  - Applied the Kernel 6.6 120 Hz WALT sweet spot (`up_rate_limit_us=4000`, `hispeed_freq=960000/1209600`, `sched_ed_boost=0`, `/proc/sys/walt/input_boost/*` `960000/60ms`, `display/cpu.uclamp.min=2`), dropping 120 Hz scrolling CPU die **`63.7 °C → 47.8 °C`** (`0.23%` jank, `p99=12 ms`) and Smart Sidebar `"All"` **`63.3 °C → 47.8 °C`**.
- **Tethering, Hotspot & 5G Standby Thermal Fixes:**
  - Restored COS16 `WCNSS_qcom_cfg.ini` (WCN7850 native hardware ARP + APFv6 offload) and stripped `-dd` verbose debug logging from `wpa_supplicant`.
  - Steered `rps_cpus=3c` dynamically across `rmnet_ipa0` (`rx-0/1`), `rmnet_data0..7`, `rndis0`, `ncm0`, `usb0`, `wlan0`, and `wlan2` (`-90.2%` `CPU0 NET_RX` softirqs during cellular/hotspot/USB tethering).
  - Upgraded DPM Fast Dormancy mask `0x028708 → 0x1AA708` (4G LTE + LTE_CA + 5G NR Fast Dormancy, `5s/3s/15s`), sinkholed 31 CN push/HTTPDNS/DCS domains in `/system/etc/hosts`, silenced QXDM/IMS/Wi-Fi crash dumps, disabled `midasd`/`ostatsd`/`ostats_pullerd`/`ostats_tpd`/`mitrustedui`/`thermalmntcfg`/`qvirtservice_rs`/`binderinfocapture`, and patched Pass-2 ELF storm culprits (`libcameraopt.so` `21,163 → 0` AVCs, `citsensorservice.aidl`, `libatlasservice.so`, `horae`, `fod-bridge.jar` binder caching).
- **Automatic One-Time Post-Setup Background `dexopt` (`cos17_dexopt_once` v2, `DEXOPT_VER=75`):** Waits for CE unlock + Setup Wizard completion (`device_provisioned=1`) + `25s` `nice(19)` settle, then compiles `SystemUI` (all 9 DEXes, `101 MB` `.odex`) and `SmartSideBar` with `-m speed` and 8 core ROM apps with `-m speed-profile` (`-61%` SystemUI jank, up to `-47%` faster cold launches).
- **Rootless Zero-Delay FCM / Push Notifications (`v7.3`):** Removed `<feature name="cn.google.services" />` from **both** `my_product/etc/permissions/oplus_google_cn_gms_features.xml` and `odm/etc/permissions/com.gnss.bds_preference.xml`, whitelisted `com.google.android.gms` in `my_region/etc/battery/sys_deviceidle_whitelist.xml`, and deployed split-scope `libNyako_hook_fcmsys.so` (`android`) + `libNyako_hook_fcmbatt.so` (`com.oplus.battery`) (`+3 ms` flag rewrite / `+18 ms` cold wake in forced Deep Doze).

### 6.4 Connectivity, eSIM, Modem, Charging, Bypass Charging & OTG
- **Global Modem Firmware Default:** Switched `images/modemfirmware.img` to Xiaomi 15 Global Stock `OS4.0.0.11.XOCMIXM` (`141,152,256 B`) by default (**CN hardware variant users should keep/flash CN `modemfirmware.img`**).
- **Full Persistent eSIM & Physical SIM 2 Support + Native COUI Settings UI:** Added `n3-route-v2` hardware multiplexer (destructive selector `5` blocked), `n3-runtime-v2.jar` with `IBinder.linkToDeath()` `500 ms` automatic endpoint recovery (fixes `owner unavailable`), `OpenEUICC` bridge (`*#*#3418#*#*` fallback), native ColorOS 17 Liquid Glass **`Manage eSIM`** UI (`DadaEsimUI` with `Capsule` squircles, 2-pass AGSL progressive top blur, `40dp` Liquid Glass back button, and `suqi8/coui` RK4 overscroll), and `TeleService` *Settings → Mobile network → Manage eSIM* entry.
- **Custom Charging Limit, 4-Stage Hardware Bypass Charging & OTG Toggle (`xmchgshim`):** Rebuilt `vendor/bin/hw/xmchgshim` (standalone C++ AIDL proxy, zero `LD_PRELOAD`) + `xmchgshim.rc`:
  - **Custom Charging Limit:** Clears `smart_night=0` and votes `chg_limit` independently across all 4 MCA paths so charging stops cleanly at any user-chosen limit instead of getting stuck at `80%`.
  - **True Hardware Bypass Charging:** Enables direct charger power across all 4 MCA stages (`buck`/`quick`/`wl_buck`/`wl_quick`) under *Settings → Battery → Charging settings*.
  - **OTG Toggle & Reverse Wireless Charging:** Fixes *Settings → Accessibility & Convenience → OTG connection* (`/sys/class/xm_power/typec/cc_toggle` + `port0/data_role`) and WLS reverse charging while keeping stock 90W HyperCharge 100% uncapped.

### 6.5 Audio, Adaptive Multi-Texture O-Haptics, Sensors & Touch
- **Native Dolby Atmos Audio Alignment:** Switched `ro.oplus.audio.effect.type=dolby` in `my_product/build.prop` matching Xiaomi 15's Dolby Atmos hardware and eliminating `AudioEffectCenter` `RuntimeException` retry spam.
- **Multi-Texture Adaptive O-Haptics & O-Haptics Demo Fix:**
  - Patched `vendor.xiaomi.hardware.vibratorfeature.service` (`slide_effect_protect_time=0` fixing fast typing lag, mid-playback `FF_GAIN` NOP'd fixing PMIC `rc=-16`, stepless `setAmplitude` scaling, widened `mi_f0_check==2` `[3071..32767]`).
  - Patched `vendor.oplus.hardware.vibrator-service` with a 404-entry PCM-verified instant-onset (`<= 2.1 ms`) 24 kHz hardware RTP table and calibrated `0.92f` scale tuning (note: overall vibration strength is slightly softer and cleaner).
  - Upgraded `vendor/bin/hw/xmvibproxy` to forward `IOplusVibrator` extension (`getExtension` fixed), synthesize RichTap HE 1.0/2.0 textures (fixing O-Haptics video demo vibration), handle `code=6` cancel stops, and use smooth single-envelope RTPs (eliminating Setup Wizard multi-burst glitches).
- **Sensor Collision & Proximity Fixes:** Remapped `tcs3408 back CCT` (`0x1fa2672 → 0x1fa2692`) in `vendor/lib64/sensors.qsh.so` eliminating 5 Hz collision with OPPO MagSafe Hall sensor; disabled unused 200 Hz wakeup crash-detection sensor `0x00000868` in `citsensorservice.aidl` while preserving Auto-Brightness and ultrasonic proximity.
- **DT2W Touch Tuning (`vendor/bin/xtouch_tune`):** Restores `MODE_DOUBLETAP=1` and calibrated tap responsiveness on sleep while preserving hardware `NONUI` pocket protection.

### 6.6 System UI, Lock Screen, Settings, Developer Options & Apps
- **PIN Instant Unlock + Circular `->` Arrow Removal:** Patched 5 Keyguard PIN classes in `SystemUI.apk` (`classes3.dex`) + `QuickUnlockPreferenceController` in `Settings.apk` — unlocks straight to the home screen instantly on `>= 4`-digit PIN without pressing Enter and hides the redundant `kgdSecurityOk` circular arrow while keeping Password mode completely untouched.
- **Post-Reset Out-of-the-Box Defaults (`cos17_defaults_v1=1` in `cos17_thermal_once` v8):** Sets Gboard as default IME, disables Secure Keyboard for passwords (`use_separate_keyboard=0`), and switches Google Mobile Services **ON** by default (`customize_control_cn_gms=1`, remains toggleable in Settings).
- **ColorOS System Launcher `v17.5.4` & Clean 4-Icon Default Dock:** Updated `OplusLauncher.apk` to `v17.5.4` (`170050004`, original Oplus V3 signature intact) and baked a clean 4-icon hotseat (*Phone, Messages, Titanium Browser, Camera*) across all 4 `default_workspace*.xml` layouts.
- **Circle to Search + Breeno Touch Coexistence:** Native rootless integration (`ContextualSearchManagerService` in `services.jar`, `DadaCircleToSearchHelper` in `SystemUI.apk`, `NavCircleToSearchUi` in `Settings.apk`) under *Settings → System & updates → System navigation → Tap and hold gesture bar* alongside Breeno Touch (keeping Breeno Touch selectable if preferred).
- **OSee (OnePlus 15 Global):** Added `OcrScanner.apk`, `BaseOcrScanner.apk`, and `OseeTileLauncher.apk` for document scanning and AI object identification.
- **OpenAlive Wallpaper (English-Translated & Integrated in Settings):** Added [`Maga-King/OpenAlive`](https://github.com/Maga-King/OpenAlive) (Flyme, HyperOS, and OriginOS wiggly live wallpapers) with 376 Chinese UI strings translated to English, root/LSPosed prompts removed, app-drawer icon hidden, and seamlessly integrated into `Wallpapers.apk` under *Settings → Home screen, Lock screen & style → More → Other → OpenAlive* with a dynamic themed XML icon.
- **Google Suite & Browser Swap:** Preinstalled Google App (`VelvetCtS`), Gemini, and Gboard; removed Via Browser; integrated [**Titanium Browser**](https://github.com/ampereforest/android-titanium-browser) with ColorOS 17 Liquid Glass UI tweaks and authentic Classic/Flux adaptive icons (fetched pre-signed so standalone APK updates install cleanly).
- **Extra Developer Options & Desktop Mode Enhancements:**
  - `Disable memory killer` (Off / 500 MB / 0 MB floor via native `cos17_memkiller_ctl`)
  - `Disable display cutout` (`DevCutoutUi` + `CutoutOverrideHelper` in `services.jar`)
  - `Enable CPU boost` (`DevCpuBoostUi` → `init.cos17_dada_perf.rc` IPC boost triggers)
  - `Enable Oplus Camera` (default OFF)
  - `ANGLE graphics driver` (`DadaAngleUI` per-app Vulkan selector)
  - Desktop Mode external-display multi-window limits lifted in `oplus-services.jar` (`persist.dpf.desktop_max_windows=10`, `persist.dpf.desktop_maximize_pct=100`).
- **Device Identity Alignment:** Aligned `my_manifest/build.prop` and `odm/etc/build.prop` from `PLK110` (`OnePlus 15`) to `PLZ110` (`OnePlus 15T`).

### 6.7 Root Integrity, Duck Detector `[Clear]`, Zero `oplusex` Mounts & Stability
- **Zero `oplusex` / `NetworkAssistSys` Overlay Mounts:** Statically baked all 26 payload files from the 6 `/system_ext/opex/*.opex` archives directly into `/system_ext/` and dual-string patched `/system_ext/lib64/libopex.so` (preserving `/my_stock/opex/Omoji.opex`).
- **Duck Detector `[Clear]` (`SELinux` & `Virtualization` Cards):**
  - Stripped `ro.kernel.qemu.gles=0` & `qemu.hw.mainkeys=0` from `system/build.prop` and remapped `qemu.sf.lcd_density` / `qemu.hw.mainkeys` out of `qemu_prop` in `plat_property_contexts` (`0` `/dev/__properties__/*qemu*` maps, preserving `520` DPI).
  - Stripped all 8 DirtySepolicy rules from `vendor_sepolicy.cil` + `system_server execmem` from `nyako.{cil,rule}` (`secilc -N NEW_PAIRS=0`).
  - Two-stage patched `libnyako_core.so`: Step A (`patch_libnyako_core.py` + `nyako_noexec_stub.c`) replaces all `execmem`/`memfd` calls with a 256 KiB file-backed `PT_LOAD[4]` COW trampoline pool; Step B (`patch_libnyako_scope.py` + `nyako_scope_filter.c`) adds a freestanding 17-scope PC-relative fast-path, UID-0 `chmod` gate, and `fsetxattr` no-op (`122 → 0` post-unlock Zygote fork stalls, `0` Nyako AVCs).
  - Labeled `/dev/socket/oplus_dnsproxyd` (`dnsproxyd_socket`) in `netd.rc` + `plat_file_contexts`, and v1+v2+v3 signed `aon.frameworkres.overlay.product.apk` (eliminating `StrictJarManifest` NPEs).
  - *Note:* Because `OpenAlive` (`org.aliveclean`) is recognized by some detectors as an LSPosed-based module package, root/integrity users may wish to hide `org.aliveclean` in `HMA-OSS`.
- **Bluetooth Toggle Reboot Loop & Contacts Boot Crash Fixes:**
  - Added `/system/etc/default-permissions/default-permissions-cos17-dada.xml` and `/my_product/etc/permissions/cos17_dada_default_grant_permissions_list.xml` so re-signed `SystemUI.apk` receives all 12 runtime permissions (`BLUETOOTH_CONNECT`, `READ_CONTACTS`, etc.) cleanly on factory reset, eliminating `reboot,ui_repair_abandoned`.
  - Added `/system/etc/sysconfig/cos17-dada-component-overrides.xml` disabling `com.android.contacts/.voicemail.impl.OmtpService` at package scan, eliminating the boot-time `NightModeUtils` recursion `StackOverflowError`.

---

## 7. Post-Setup Thermal Notice

> **Note:** Right after completing initial Setup Wizard on a clean flash, the phone may feel warm for a short period as one-time background optimizations (`cos17_dexopt_once` ART compilation, `cos17_thermal_once` initial hygiene, and Google/system account sync) run automatically. Please wait around **15–30 minutes** for everything to finish, after which idle and active temperatures will settle normally (`~0.79%` screen-off idle CPU / `~63–72 mA` standby draw).

---

## 8. Optional Companion Kernel (`wild-trsy` `r24`)

For users who want optional root or additional KMI-safe kernel-level idle efficiency, an optional companion **`6.6.118-android15-wild-trsy`** GKI kernel (WildKernel fork) is published at:

- **[`ampereforest/GKI_KernelSU_SUSFS` — Release `r24`](https://github.com/ampereforest/GKI_KernelSU_SUSFS/releases/tag/r24)**

Highlights:
- Built with **KernelSU**, **SUSFS**, **NoMount** compatibility, and **DroidSpaces** enabled.
- Includes stock-KMI-safe (`9,317` ABI symbols, **`0` drift**) power-efficiency defconfig tweaks (`CONFIG_WQ_POWER_EFFICIENT_DEFAULT=y` and `# CONFIG_RCU_LAZY_DEFAULT_OFF is not set` — see [`modules/01-thermal-heat-ltpo-fcm/docs/KERNEL-GKI-TWEAKS.md`](modules/01-thermal-heat-ltpo-fcm/docs/KERNEL-GKI-TWEAKS.md)) that schedule background workqueues onto already-awake cores and batch non-urgent RCU callbacks to reduce idle wakeups and standby warmth with zero performance caps.

---

## 9. Credits

- **TUSB_5834@Coolapk** — Original base ColorOS 17 V6 port ROM for Xiaomi 15 (`dada`).
- **@adrenolaboratory** — Adreno GPU driver updates (`EGL v842.52` / `Vulkan 1.4 512.842.52`).
- **@meyus23** — LTPO and eSIM base work.
- **@amazingarcader** — HDR peak brightness and Bypass Charging guides.
- **@Chaitanya_Yeranagula** — Supporting the ROM optimization work.
- **PeterCxy** ([OpenEUICC](https://gitea.angry.im/PeterCxy/OpenEUICC)), **Kyant0** ([Capsule](https://github.com/Kyant0/Capsule), [AndroidLiquidGlass](https://github.com/Kyant0/AndroidLiquidGlass)), **suqi8** ([coui](https://github.com/suqi8/coui)), **Maga-King** ([OpenAlive](https://github.com/Maga-King/OpenAlive)), and everyone else who helped build, test, and refine this ROM!
