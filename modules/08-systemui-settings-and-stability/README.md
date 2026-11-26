# Module 08 — SystemUI, Settings, PIN Instant Unlock, Circle to Search, DevOpts & Crash Fixes

## Contents
- `patches/`:
  - `systemui_classes3_pin_instant_unlock.smali.patch` — Instant PIN unlock (`len >= 4`) without pressing Enter + hides redundant circular `->` arrow (`kgdSecurityOk`) while leaving Password mode untouched
  - `systemui_classes4_circle_to_search.smali.patch` — Native rootless Circle to Search gesture-bar long-press (`DadaCircleToSearchHelper`, `SpeedChassistMainBusiness`, `OplusNavigationHandle`, `OplusOcrScreenBusiness`) coexisting with Breeno Touch
  - `settings_classes_hdr_saturation_devopts.smali.patch` & `settings_classes2_cts_devopts_quickunlock.smali.patch` — `HDR Level`, `0..200` Inline SDR Saturation, Developer Options (`Disable memory killer`, `Disable cutout`, `Enable CPU boost`, `Enable Oplus Camera`, `ANGLE graphics driver`), Circle to Search nav-bar toggle, and `QuickUnlockPreferenceController`
  - `services_classes2_contextual_search.smali.patch` — Unconditionally starts `ContextualSearchManagerService` for Google Velvet
  - `services_classes4_disable_cutout.smali.patch` — `CutoutOverrideHelper` + `DisplayPolicy`
  - `my_product_osense_memory_config.patch` — OSense memory config for `Disable memory killer`
  - `my_manifest_identity_plz110.patch` — Device identity alignment `PLK110 -> PLZ110` (`OnePlus 15T`)
  - `default_workspace_{main,simple,id,ru}.patch` — Clean 4-icon default dock (*Phone, Messages, Titanium Browser, MiuiCamera*)
- `configs/`:
  - **Bluetooth Toggle Reboot-Loop Fix:** `system/etc/default-permissions/default-permissions-cos17-dada.xml` + `my_product/etc/permissions/cos17_dada_default_grant_permissions_list.xml` (restores all 12 runtime permissions for re-signed `SystemUI.apk` on clean flash)
  - **Contacts Boot Crash Fix:** `system/etc/sysconfig/cos17-dada-component-overrides.xml` (disables `com.android.contacts/.voicemail.impl.OmtpService`)
  - **Google Velvet / Lens / Circle to Search Permissions & Sysconfig:** 5 XML files under `product/etc/{permissions,sysconfig}/`
