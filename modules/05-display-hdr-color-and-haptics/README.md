# Module 05 — Display, 3200-Nit HDR, Inline SDR Saturation, Charging/OTG & Adaptive O-Haptics

Upstream companion repositories:
- [`ampereforest/dada_hdr_compat_for_ported_rom`](https://github.com/ampereforest/dada_hdr_compat_for_ported_rom)
- [`ampereforest/android-adaptive-haptics`](https://github.com/ampereforest/android-adaptive-haptics)

## Contents
- `display-hdr/`:
  - `patches/vendor_display_id_4630946682710401939.patch` — 3200-nit HDR/HBM spline & `sdrHdrRatioMap`
  - `patches/my_product_oplus_feature_hdr.patch` — HDR brightness & Dolby enhance feature flags
  - `patches/my_product_oplus_vrr_config.patch` & `my_product_refresh_rate_config.patch` — 1–120 Hz LTPO & MiuiCamera VRR rules
  - `patches/vendor_init_qti_display_boot.patch` — QTI display boot alignment
  - `patches/oplus_services_classes_hdr_edr.smali.patch` — `4.9f` HDR headroom & EDR UI dimming fix
  - `patches/oplus_services_classes3_vrr_desktop.smali.patch` — LTPO IME refresh rate policy & Desktop Mode multi-window limits (`persist.dpf.desktop_max_windows=10`, `persist.dpf.desktop_maximize_pct=100`)
  - `patches/services_classes2_hdr_saturation.smali.patch` — `InlineSdrSaturationController`, `ColorDisplayService`, `DisplayTransformManager`
  - `assets/hdr_level_banner.png` — `1098×672` banner placed into `Settings.apk/assets/`
  - `scripts/patch_displayfeature_and_sdm.py` — Offset-verified patcher for `odm/lib64/hw/displayfeature.default.so` (5 insns) & `vendor/lib64/libsdmextension.so` (1 insn)
- `charging-otg/`:
  - `src/xmchgshim.cpp` & `prebuilt/vendor/bin/hw/xmchgshim` — Standalone NDK C++ AIDL `ICharger/default` proxy (OTG toggle, WLS reverse charging, uncapped Custom Charging Limit clearing `smart_night=0`, and 4-stage Bypass Charging across `buck`/`quick`/`wl_buck`/`wl_quick`)
  - `patches/vendor_xmchgshim_rc.patch` — Permissions & init triggers
- `haptics/`:
  - `scripts/patch_vib_binaries.py` — Offset-verified patcher for `odm/bin/hw/vendor.xiaomi.hardware.vibratorfeature.service` (zero `rc=-16`, `slide_effect_protect_time=0`, continuous amplitude, widened `mi_f0_check==2`) and `odm/bin/hw/vendor.oplus.hardware.vibrator-service` (404-entry PCM-verified `<= 2.1 ms` instant-onset 24 kHz RTP table + `0.92f` scale calibration)
  - Companion event-driven `xmvibproxy` binary & source live in `modules/01-thermal-heat-ltpo-fcm/`
