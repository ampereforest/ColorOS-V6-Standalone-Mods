# Module 07 — ColorOS Gallery Editor 5-Lib SIGSEGV Fix & Static `/system_ext/opex` Baking

## Contents
- `gallery-editor/scripts/patch_gallery_3base_libs.py`:
  - Offset-verified patcher fixing instant `PhotoEditorActivity` native `SIGSEGV` crashes across base V6 libraries:
    1. `my_product/lib64/libMsEffectSdk.so` (zeroes 14 uninitialized `.data` `mIs*` flags at `0x5ba30`)
    2. `my_product/lib64/libAPSClient-cmd-jni.so` (NOPs two unchecked `blr x8` calls at `0x778c0`/`0x778d0`)
    3. `system_ext/lib64/libAPSClient-cmd-jni-extension.oplus.so` (NOPs two unchecked `blr x8` calls at `0x77844`/`0x77854`)
  - The 2 additional PMX110 libraries (`product/lib64/libMsEffectSdk.so` & `product/lib64/libAPSClient-cmd-jni.so`) inside `modules/04-camera-oplus-experimental/product/lib64/` are already pre-patched, completing all 5 libraries.
  - Keep `com.oplus.aiunit` and `com.oplus.deepthinker` unblocked so all 8 ColorOS 17 AI Editor tools run cleanly on demand.
- `opex-static-bake/system_ext/`:
  - All 26 payload files extracted from the 6 `/system_ext/opex/*.opex` archives (`NetworkAssistSys.apk`, `CustCore.apk`, `framework/oplusex/*`, `lib64/oplusex/*`, `etc/raw/*.glsl`, `etc/permissions/permission-lib.xml`, `etc/sdkinfo.pb`).
  - Pair with `modules/01-thermal-heat-ltpo-fcm/scripts/patch_libopex.py` to eliminate all `oplusex` / `NetworkAssistSys` runtime loop + overlayfs mounts while preserving `/my_stock/opex/Omoji.opex`.
