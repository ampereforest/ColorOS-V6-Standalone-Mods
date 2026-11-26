# Module 06 — Adreno GPU v842.52 (Vulkan 1.4), ANGLE (`DadaAngleUI`) & ColorOS 17 URCC HAL

## Contents
- `adreno-v842.52/`:
  - All 42 pre-made `vendor/lib{,64}/` Adreno `EGL v842.52` / `Vulkan 1.4 512.842.52` + `vendor.qti.hardware.hexlp-V2-ndk.so` libraries (credit: `@adrenolaboratory`)
  - `vendor/etc/permissions/android.hardware.vulkan.version-1_4.xml`
  - `patches/vendor_{opengles,vulkan}_deqp_level.patch` (`2025-03-01` dEQP levels)
- `angle/`:
  - `src/dada-angle-ui/` — Full Jetpack Compose COUI 17 per-app ANGLE/Vulkan graphics driver selector source
  - `prebuilt/product/priv-app/DadaAngleUI/DadaAngleUI.apk` (re-signed automatically by `signing/sign_rom_apks.sh`)
  - `product/etc/permissions/privapp-permissions-dadaangleui.xml`
- `urcc-hal/`:
  - 5 ColorOS 17 `PLZ110` URCC/UAH HAL binaries/libraries (`odm/bin/hw/vendor.oplus.hardware.urcc-service`, `odm/lib64/{liboplus-uah-client,libuahcore,liburcccore,vendor.oplus.hardware.urcc-V1-ndk}.so`)
  - `patches/odm_{file,service}_contexts.patch` (registers `hal_urcc_service` so `uah`/`urcc` binds cleanly)
