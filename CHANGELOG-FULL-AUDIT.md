# Full ROM Diff Audit Ledger: Base ColorOS 17 V6 (`Xiaomi15_ColorOS17_V6.zip`) → `MOD@tarosaiya` (`v7.3.1`)

This reference documents the exact, verified partition-by-partition file diff between TUSB_5834@Coolapk's original base ROM (`Xiaomi15_ColorOS17_V6.zip`, `PLZ110_17.0.0.107(CN01)`) and our completed rootless **`v7.3.1`** build for **Xiaomi 15 (`dada`, `24129PN74G`, SM8750)**.

---

## Partition Summary (`7/7` Dynamic Partitions + Firmware Images)

| Partition / Image | Base Files | Final Files | Added | Removed | Modified | Module(s) |
| :--- | :---: | :---: | :---: | :---: | :---: | :--- |
| **`odm`** | 3,238 | 3,264 | +26 | 0 | 21 | 01, 03, 04, 05, 06 |
| **`product`** | 300 | 396 | +100 | -4 | 4 | 01, 02, 03, 04, 06, 08, 09 |
| **`system`** *(incl. `my_product`, `my_region`, `my_stock`, `my_manifest`)* | 9,381 | 9,409 | +39 | -11 | 400 *(44 non-OAT + BCP ART/OAT)* | 01, 02, 03, 04, 05, 07, 08, 09 |
| **`system_dlkm`** | 213 | 213 | 0 | 0 | 0 | Unchanged |
| **`system_ext`** | 3,594 | 3,617 | +26 | -3 | 30 *(22 non-OAT)* | 01, 02, 05, 07, 08, 09 |
| **`vendor`** | 3,278 | 3,290 | +12 | 0 | 63 *(40 GPU libs + 23 configs/HALs)* | 01, 05, 06 |
| **`vendor_dlkm`** | 404 | 404 | 0 | 0 | 0 | Unchanged |
| **`images/modemfirmware.img`** | `136,876,032 B` (CN) | `141,152,256 B` (Global) | — | — | Replaced | 10 *(GitHub Release asset)* |

All other firmware images outside `super.img` (`abl`, `aop`, `bluetooth`, `boot`, `dsp`, `dtbo`, `hyp`, `init_boot`, `keymaster`, `modem`, `recovery`, `tz`, `uefi`, `vbmeta`, `vbmeta_system`, `vendor_boot`, `xbl`, etc.) are **bit-for-bit identical** to base V6.

---

## Detailed File-by-File Inventory by Partition

### 1. `odm` (+26, ~21)
- **Added (26):** `etc/camera/config/*` (26 OPPO `PMX110` camera configuration files — Module 04).
- **Modified Text/Config (11):**
  - `etc/ThermalServiceConfig/sys_thermal_config.xml` (`thermal_zone57`, `is_upload_dcs=0` — Module 01)
  - `etc/build.prop` (`PLK110 -> PLZ110`, `OnePlus 15 -> OnePlus 15T`, `iostat`/`fault_report=false`, `slide_effect_protect_time=0`, `capdepth`/`capbokeh.debuglitemode=0` — Modules 01, 03)
  - `etc/camera/dualcam_{bokeh,depth,predepth}_params_pro.json` (Portrait depth & non-human detection — Module 03)
  - `etc/init/vendor.oplus.hardware.thermalmntcfg@1.0-service.rc` (`disabled` — Module 01)
  - `etc/init/vendor.xiaomi.hardware.mitrustedui.rc` (`stop vendor.mitrustedui` on boot_completed — Module 01)
  - `etc/permissions/com.gnss.bds_preference.xml` (stripped `cn.google.services` — Module 01)
  - `etc/selinux/odm_{file,service}_contexts` (`vendor.oplus.hardware.urcc-service` & `hal_urcc_service` — Module 06)
  - `etc/thermalbreakboostconfig.xml` (neutralized `<PerfBreak/>` — Module 01)
- **Modified Binaries/Libraries (10):**
  - `bin/hw/oplus-color-mode-sync` (0-jiffy futex patch — Module 01)
  - `bin/hw/vendor.xiaomi.sensor.citsensorservice.aidl` (Pass 2 culprit patch — Module 01)
  - `bin/hw/vendor.oplus.hardware.vibrator-service` & `bin/hw/vendor.xiaomi.hardware.vibratorfeature.service` (Adaptive multi-texture haptics + `0.92f` scale — Module 05)
  - `lib64/hw/displayfeature.default.so` (5-insn 3200-nit HDR patch — Module 05)
  - `bin/hw/vendor.oplus.hardware.urcc-service`, `lib64/{liboplus-uah-client,libuahcore,liburcccore,vendor.oplus.hardware.urcc-V1-ndk}.so` (`PLZ110` ColorOS 17 URCC/UAH HAL — Module 06)

### 2. `product` (+100, -4, ~4)
- **Added (100):**
  - APKs: `app/Gemini/Gemini.apk` (5.4 MB), `app/LatinImeGoogle/LatinImeGoogle.apk` (76.2 MB), `app/OpenAlive/OpenAlive.apk` (630.3 MB, Release asset) + 3 `app/OpenAlive/lib/arm64/*.so`, `app/TitaniumBrowser/TitaniumBrowser.apk` (fetched pre-signed from `ampereforest/android-titanium-browser`), `priv-app/DadaAngleUI/DadaAngleUI.apk`, `priv-app/DadaEsimUI/DadaEsimUI.apk`, `priv-app/OpenEUICC/OpenEUICC.apk`, `priv-app/VelvetCtS/VelvetCtS.apk` (305.4 MB, Release asset).
  - Permissions & Sysconfig (10 XMLs): Google Lens Camera/Gallery, Google Velvet privapp, Contextual Search, Google Velvet/Gemini, OplusCamera SDK & default grants, DadaAngleUI, DadaEsimUI, OpenEUICC.
  - OplusCamera SDK & Libraries: `framework/com.oplus.camera.unit.sdk{,.adapter}.jar` + 77 `lib64/*.so` (note: `libMsEffectSdk.so` & `libAPSClient-cmd-jni.so` pre-patched for Gallery Editor SIGSEGV fix).
- **Removed (4):** Stale `framework/oat/{arm,arm64}/ims-ext-common.{odex,vdex}` (Module 01).
- **Modified (4):** `etc/build.prop` (`persist.oplus.qspa.modem=disabled`), `framework/ims-ext-common.jar` (`QtiImsExtConnector` bind-storm guard), `lib64/libc++.so` (OplusCamera), `priv-app/MiuiCamera/MiuiCamera.apk` (DNG thumbnail, top-menu crash fix, ColorOS adaptive icons).

### 3. `system` *(including `my_product`, `my_region`, `my_stock`, `my_manifest`)* (+39, -11, ~44 non-OAT)
- **Added (39):**
  - `my_product/app/OplusCamera/OplusCamera.apk` (173.8 MB, Release asset)
  - `my_product/etc/permissions/cos17_dada_default_grant_permissions_list.xml` (SystemUI clean-flash runtime grants — Module 08)
  - `my_product/media/theme/uxicons/hdpi/io.github.jqssun.helium/*` (25 Titanium Browser Classic & Flux icon PNGs — Module 09)
  - `my_stock/del-app/OcrScanner/OcrScanner.apk` (114.5 MB, Release asset) & `OseeTileLauncher.apk` (Module 09)
  - `system/bin/n3-route-v2`, `system/etc/init/n3-route-v2.rc`, `system/framework/n3-runtime-v2.jar` (+ `.fsv_meta`) (Module 02)
  - `system/etc/default-permissions/default-permissions-cos17-dada.xml` & `system/etc/sysconfig/cos17-dada-component-overrides.xml` (Bluetooth reboot-loop & Contacts `OmtpService` crash fixes — Module 08)
  - `system/lib64/libNyako_hook_{fcmsys,fcmbatt}.so` (Module 01) & `system/lib64/libdada_{camfix,rtfix}.so` (Module 03)
- **Removed (11):** `my_stock/app/Via/Via.apk`, stale `services` oat/fsv_meta (7 files), stale `com.oplus.camera.unit.sdk.{odex,vdex}`, stale `Wallpapers.vdex`.
- **Modified Non-OAT (44):**
  - Props & XMLs: `my_manifest/build.prop`, `my_product/build.prop`, `my_product/cust/CN/build.prop`, 4× `default_workspace*.xml`, `com.oplus.oplus-feature.xml`, `sys_custom_osense_memory_config.xml`, `oplus_vrr_config.json`, `oplus_google_cn_gms_features.xml`, `refresh_rate_config.xml`, `sys_global_uni_render_list.xml`, `display_brightness_app_list.xml`, `my_region/etc/battery/sys_deviceidle_whitelist.xml`, `my_stock/applist/applist.txt`, `my_stock/etc/ThermalServiceConfig/sys_thermal_config.xml`, `morph_icons_whitelist.xml`, `system/build.prop`, `system/etc/hosts`, `system/etc/init/{hw/init.rc,ltpo_overlay.rc,netd.rc}`, `system/etc/selinux/{nyako.cil,nyako.rule,plat_file_contexts,plat_property_contexts,plat_sepolicy.cil,plat_sepolicy_and_mapping.sha256}`.
  - Native Binaries / Libraries / JARs / APKs: `my_product/lib64/{libMsEffectSdk.so,libAPSClient-cmd-jni.so}`, `my_product/overlay/aon.frameworkres.overlay.product.apk` (re-signed v1+v2+v3), `my_product/product_overlay/framework/com.oplus.camera.unit.sdk.jar`, `my_stock/app/BaseOcrScanner/BaseOcrScanner.apk`, `my_stock/priv-app/Wallpapers/Wallpapers.apk`, `system/bin/surfaceflinger`, `system/etc/mifod/fod-bridge.jar`, `system/framework/{services.jar,oplus-services.jar,telephony-common.jar}` (+ regenerated BCP ART/OAT), `system/lib64/{libnyako_core.so,overlay.so,libNyako_hook_ltpofix.so,libandroid_runtime.so,libcameraservice.so}`.

### 4. `system_ext` (+26, -3, ~22 non-OAT)
- **Added (26):** Complete statically baked payloads from all 6 `/system_ext/opex/*.opex` archives (`app/NetworkAssistSys/NetworkAssistSys.apk`, `priv-app/CustCoreApp/CustCore.apk`, `framework/oplusex/*`, `lib64/oplusex/*`, `etc/raw/*.glsl`, `etc/permissions/permission-lib.xml`, `etc/sdkinfo.pb` — Module 07).
- **Removed (3):** Stale `priv-app/Settings/oat/arm64/Settings.{art,odex,vdex}`.
- **Modified Non-OAT (22):**
  - Configs/RCs/SELinux: `etc/dpm/dpm.conf`, `etc/init/{init.oplus.debug.rc,midasd.rc,ostats_pullerd.rc,ostats_tpd.rc,ostatsd.rc}`, `etc/selinux/{plat_sepolicy_debug.cil,plat_sepolicy_and_mapping_debug.sha256}`.
  - Binaries/Libraries/APKs/JARs: `bin/horae`, `lib64/{libAPSClient-cmd-jni-extension.oplus.so,libatlasservice.so,libopex.so}`, `framework/oplus-telephony-common.jar`, `priv-app/OplusLauncher/OplusLauncher.apk` (`v17.5.4`), `priv-app/Settings/Settings.apk`, `priv-app/SystemUI/SystemUI.apk`, `priv-app/TeleService/TeleService.apk`.

### 5. `vendor` (+12, ~63)
- **Added (12):** `bin/{cos17_dexopt_once,cos17_memkiller_ctl,cos17_thermal_once,hdrpeakd,xtouch_tune}`, `etc/init/{cos17_daemons.rc,cos17_dexopt.rc,hdrpeak.rc,init.cos17_dada_perf.rc}`, `etc/permissions/android.hardware.vulkan.version-1_4.xml`, `lib{,64}/vendor.qti.hardware.hexlp-V2-ndk.so`.
- **Modified (63):**
  - 40 Adreno `V842.52` EGL / Vulkan 1.4 / OpenCL / LLVM driver libraries across `lib/` and `lib64/` (Module 06).
  - 3 patched vendor HAL/native binaries: `bin/hw/xmchgshim`, `bin/hw/xmvibproxy`, `lib64/{libcameraopt.so,libsdmextension.so,sensors.qsh.so}`.
  - 18 text/XML/RC/SELinux/shell configs: `bin/hw/hdrblfollow.sh`, `bin/init.kernel.post_boot-memory.sh`, `bin/init.qti.display_boot.sh`, `build.prop`, `etc/display/thermallevel_to_fps.xml`, `etc/displayconfig/display_id_4630946682710401939.xml`, `etc/dpm_vndr/vendor.dpm.conf`, `etc/init/{android.hardware.wifi.supplicant-service.rc,hdrblfollow.rc,xmchgshim.rc}`, `etc/perf/{perfboostsconfig.xml,perfconfigstore.xml,thermalbreakboostconfig.xml}`, `etc/permissions/android.software.{opengles,vulkan}.deqp.level.xml`, `etc/selinux/{vendor_file_contexts,vendor_sepolicy.cil}`, `etc/wifi/peach_v2/WCNSS_qcom_cfg.ini`.
