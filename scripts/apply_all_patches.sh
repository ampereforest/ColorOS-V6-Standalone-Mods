#!/usr/bin/env bash
# End-to-end helper to apply text/config patches, install pre-made binaries & non-V6 assets,
# run all offset-verified AArch64 ELF binary patchers, and bind your local signing/keys/
# certificates onto an unpacked ColorOS 17 V6 ROM tree (Xiaomi 15 / dada).
#
# Expected ROM tree layout at --rom-root:
#   <rom-root>/odm/
#   <rom-root>/product/
#   <rom-root>/system/          (containing system/, my_product/, my_region/, my_stock/, my_manifest/)
#   <rom-root>/system_ext/
#   <rom-root>/vendor/
#
# Usage:
#   bash signing/generate_keys.sh
#   bash scripts/fetch_release_assets.sh
#   bash scripts/apply_all_patches.sh --rom-root /path/to/unpacked_rom
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
ROM_ROOT=""
SKIP_RELEASE_ASSETS=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --rom-root) ROM_ROOT="$2"; shift 2 ;;
    --skip-release-assets) SKIP_RELEASE_ASSETS=1; shift ;;
    -h|--help)
      echo "Usage: $0 --rom-root /path/to/unpacked_rom [--skip-release-assets]"
      exit 0
      ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$ROM_ROOT" || ! -d "$ROM_ROOT/system" || ! -d "$ROM_ROOT/vendor" ]]; then
  echo "ERROR: Pass --rom-root pointing to an unpacked ColorOS 17 V6 tree (odm/, product/, system/, system_ext/, vendor/)." >&2
  exit 1
fi

# Verify signing keys exist and stamp SHA-256 into framework/eSIM patches
if [[ ! -f "${REPO_ROOT}/signing/keys/platform.x509.pem" ]]; then
  echo "ERROR: signing/keys/platform.x509.pem not found. Run 'bash signing/generate_keys.sh' first." >&2
  exit 1
fi
python3 "${REPO_ROOT}/signing/render_framework_signer.py"

apply_patch() {
  local pfile="$1"
  local target_dir="$ROM_ROOT"
  # Patch paths starting with my_* or system/* live inside <rom-root>/system/ in super.img layout
  local first_target
  first_target="$(grep -m1 '^+++ ' "$pfile" | awk '{print $2}' | sed 's|^b/||')"
  if [[ "$first_target" == my_* || "$first_target" == system/* ]]; then
    target_dir="${ROM_ROOT}/system"
  fi
  echo "[PATCH] $(realpath --relative-to="$REPO_ROOT" "$pfile") -> ${target_dir}"
  patch -p1 -d "$target_dir" -i "$pfile"
}

echo "=== 1. Applying Module 01 (Thermal, Heat, Smoothness, LTPO, FCM, SELinux) Patches ==="
M01="${REPO_ROOT}/modules/01-thermal-heat-ltpo-fcm"
for p in \
  patches/01-thermal-perf/vendor_thermalbreakboostconfig.patch \
  patches/01-thermal-perf/vendor_perfboostsconfig.patch \
  patches/01-thermal-perf/vendor_perfconfigstore.patch \
  patches/01-thermal-perf/odm_sys_thermal_config.patch \
  patches/01-thermal-perf/my_stock_sys_thermal_config.patch \
  patches/01-thermal-perf/vendor_thermallevel_to_fps.patch \
  patches/02-display-ltpo-cwb/my_product_display_brightness_als.patch \
  patches/02-display-ltpo-cwb/my_product_unirender_disable.patch \
  patches/02-display-ltpo-cwb/system_ltpo_overlay_rc.patch \
  patches/02-display-ltpo-cwb/vendor_hdrblfollow_rc.patch \
  patches/03-telephony-wifi-rps/vendor_dpm_fast_dormancy.patch \
  patches/03-telephony-wifi-rps/system_ext_dpm_fast_dormancy.patch \
  patches/03-telephony-wifi-rps/system_hosts_cn_telemetry_sinkhole.patch \
  patches/03-telephony-wifi-rps/vendor_wcnss_qcom_cfg.patch \
  patches/03-telephony-wifi-rps/vendor_wpa_supplicant_rc.patch \
  patches/03-telephony-wifi-rps/system_init_rc_hygiene.patch \
  patches/03-telephony-wifi-rps/system_netd_oplus_dnsproxyd.patch \
  patches/03-telephony-wifi-rps/system_plat_file_contexts_dnsproxyd.patch \
  patches/03-telephony-wifi-rps/system_plat_property_contexts.patch \
  patches/03-telephony-wifi-rps/system_nyako_cil.patch \
  patches/03-telephony-wifi-rps/system_nyako_rule.patch \
  patches/03-telephony-wifi-rps/system_ext_init_oplus_debug_rc.patch \
  patches/03-telephony-wifi-rps/system_ext_midasd_rc.patch \
  patches/03-telephony-wifi-rps/system_ext_ostatsd_rc.patch \
  patches/03-telephony-wifi-rps/system_ext_ostats_pullerd_rc.patch \
  patches/03-telephony-wifi-rps/system_ext_ostats_tpd_rc.patch \
  patches/03-telephony-wifi-rps/odm_thermalmntcfg_rc.patch \
  patches/03-telephony-wifi-rps/odm_mitrustedui_rc.patch \
  patches/03-telephony-wifi-rps/odm_build_prop_hygiene.patch \
  patches/03-telephony-wifi-rps/product_build_prop_qspa.patch \
  patches/03-telephony-wifi-rps/my_product_ims_audio_props.patch \
  patches/03-telephony-wifi-rps/my_product_cust_cn_regionlock.patch \
  patches/03-telephony-wifi-rps/vendor_file_contexts.patch \
  patches/03-telephony-wifi-rps/vendor_sepolicy_cil.patch \
  patches/04-memory-vm-props/vendor_post_boot_memory_watermark.patch \
  patches/04-memory-vm-props/system_build_prop_hygiene.patch \
  patches/04-memory-vm-props/vendor_build_prop_thermal_hygiene.patch \
  patches/06-stability-fcm-ims/my_product_cn_gms_features.patch \
  patches/06-stability-fcm-ims/odm_gnss_bds_preference.patch \
  patches/06-stability-fcm-ims/my_region_deviceidle_whitelist.patch
do
  apply_patch "${M01}/${p}"
done
cp -f "${M01}/patches/01-thermal-perf/odm_thermalbreakboostconfig.xml" "${ROM_ROOT}/odm/etc/thermalbreakboostconfig.xml"

echo "=== 2. Applying Modules 03, 05, 06, 08, 09 Text/XML/Config Patches ==="
for p in \
  modules/03-camera-leica-miuicamera/patches/dualcam_bokeh_params_pro.patch \
  modules/03-camera-leica-miuicamera/patches/dualcam_depth_params_pro.patch \
  modules/03-camera-leica-miuicamera/patches/dualcam_predepth_params_pro.patch \
  modules/05-display-hdr-color-and-haptics/display-hdr/patches/vendor_display_id_4630946682710401939.patch \
  modules/05-display-hdr-color-and-haptics/display-hdr/patches/my_product_oplus_feature_hdr.patch \
  modules/05-display-hdr-color-and-haptics/display-hdr/patches/my_product_oplus_vrr_config.patch \
  modules/05-display-hdr-color-and-haptics/display-hdr/patches/my_product_refresh_rate_config.patch \
  modules/05-display-hdr-color-and-haptics/display-hdr/patches/vendor_init_qti_display_boot.patch \
  modules/05-display-hdr-color-and-haptics/charging-otg/patches/vendor_xmchgshim_rc.patch \
  modules/06-gpu-adreno-angle-and-urcc/adreno-v842.52/patches/vendor_opengles_deqp_level.patch \
  modules/06-gpu-adreno-angle-and-urcc/adreno-v842.52/patches/vendor_vulkan_deqp_level.patch \
  modules/06-gpu-adreno-angle-and-urcc/urcc-hal/patches/odm_file_contexts.patch \
  modules/06-gpu-adreno-angle-and-urcc/urcc-hal/patches/odm_service_contexts.patch \
  modules/08-systemui-settings-and-stability/patches/my_product_osense_memory_config.patch \
  modules/08-systemui-settings-and-stability/patches/my_manifest_identity_plz110.patch \
  modules/08-systemui-settings-and-stability/patches/default_workspace_main.patch \
  modules/08-systemui-settings-and-stability/patches/default_workspace_simple.patch \
  modules/08-systemui-settings-and-stability/patches/default_workspace_id.patch \
  modules/08-systemui-settings-and-stability/patches/default_workspace_ru.patch \
  modules/09-apps-and-ui/osee-op15-global/patches/my_stock_applist_osee.patch \
  modules/09-apps-and-ui/titanium-browser/patches/my_stock_morph_icons_whitelist.patch
do
  apply_patch "${REPO_ROOT}/${p}"
done

echo "=== 3. Installing Pre-Made Custom Binaries, Init RCs & Non-V6 Assets ==="
cp -a "${M01}/prebuilt/system/." "${ROM_ROOT}/system/system/"
cp -a "${M01}/prebuilt/vendor/." "${ROM_ROOT}/vendor/"
cp -f "${M01}/src/init/"{cos17_daemons,cos17_dexopt,hdrpeak,init.cos17_dada_perf}.rc "${ROM_ROOT}/vendor/etc/init/"
cp -f "${M01}/src/init/ltpo_overlay.rc" "${ROM_ROOT}/system/system/etc/init/"

# Module 02: eSIM native binary, init, permissions, APKs (re-signed at end!)
M02="${REPO_ROOT}/modules/02-esim-compat"
cp -f "${M02}/prebuilt/system/bin/n3-route-v2" "${ROM_ROOT}/system/system/bin/n3-route-v2"
cp -f "${M02}/config/system/etc/init/n3-route-v2.rc" "${ROM_ROOT}/system/system/etc/init/n3-route-v2.rc"
cp -f "${M02}/config/etc/permissions/privapp-permissions-openeuicc.xml" "${ROM_ROOT}/product/etc/permissions/"
cp -f "${M02}/dada-esim-ui/privapp-permissions-dadaesimui.xml" "${ROM_ROOT}/product/etc/permissions/"
mkdir -p "${ROM_ROOT}/product/priv-app/OpenEUICC" "${ROM_ROOT}/product/priv-app/DadaEsimUI"
cp -f "${M02}/prebuilt/product/priv-app/OpenEUICC/OpenEUICC.apk" "${ROM_ROOT}/product/priv-app/OpenEUICC/"
cp -f "${M02}/prebuilt/product/priv-app/DadaEsimUI/DadaEsimUI.apk" "${ROM_ROOT}/product/priv-app/DadaEsimUI/"
cat "${M02}/config/selinux/file_contexts.additions" >> "${ROM_ROOT}/system/system/etc/selinux/plat_file_contexts"

# Module 03: Leica MiuiCamera native shims
cp -a "${REPO_ROOT}/modules/03-camera-leica-miuicamera/prebuilt/system/." "${ROM_ROOT}/system/system/"

# Module 04: Experimental OplusCamera SDK, odm configs, product/lib64 libs
M04="${REPO_ROOT}/modules/04-camera-oplus-experimental"
cp -a "${M04}/odm/." "${ROM_ROOT}/odm/"
cp -a "${M04}/product/." "${ROM_ROOT}/product/"
cp -f "${M04}/product/framework/com.oplus.camera.unit.sdk.jar" "${ROM_ROOT}/system/my_product/product_overlay/framework/com.oplus.camera.unit.sdk.jar"
rm -f "${ROM_ROOT}/system/my_product/product_overlay/framework/oat/arm64/com.oplus.camera.unit.sdk."{odex,vdex}

# Module 05: xmchgshim
cp -f "${REPO_ROOT}/modules/05-display-hdr-color-and-haptics/charging-otg/prebuilt/vendor/bin/hw/xmchgshim" "${ROM_ROOT}/vendor/bin/hw/xmchgshim"

# Module 06: Adreno v842.52, DadaAngleUI, URCC HAL
M06="${REPO_ROOT}/modules/06-gpu-adreno-angle-and-urcc"
cp -a "${M06}/adreno-v842.52/vendor/." "${ROM_ROOT}/vendor/"
cp -a "${M06}/angle/prebuilt/product/." "${ROM_ROOT}/product/"
cp -a "${M06}/angle/product/." "${ROM_ROOT}/product/"
cp -a "${M06}/urcc-hal/odm/." "${ROM_ROOT}/odm/"

# Module 07: Static /system_ext/opex payloads
cp -a "${REPO_ROOT}/modules/07-gallery-editor-and-opex/opex-static-bake/system_ext/." "${ROM_ROOT}/system_ext/"

# Module 08: Stability, Bluetooth, Contacts & Google/CtS XML configs
M08="${REPO_ROOT}/modules/08-systemui-settings-and-stability/configs"
cp -a "${M08}/system/." "${ROM_ROOT}/system/system/"
cp -a "${M08}/my_product/." "${ROM_ROOT}/system/my_product/"
cp -a "${M08}/product/." "${ROM_ROOT}/product/"

# Module 09: Launcher 17.5.4, OSee, OpenAlive libs, Gemini, Gboard, Titanium uxicons; remove Via
M09="${REPO_ROOT}/modules/09-apps-and-ui"
cp -a "${M09}/launcher-17.5.4/system_ext/." "${ROM_ROOT}/system_ext/"
cp -a "${M09}/osee-op15-global/my_stock/." "${ROM_ROOT}/system/my_stock/"
cp -a "${M09}/openalive-wallpaper/product/." "${ROM_ROOT}/product/"
cp -a "${M09}/google-suite/product/." "${ROM_ROOT}/product/"
cp -a "${M09}/titanium-browser/my_product/." "${ROM_ROOT}/system/my_product/"
rm -rf "${ROM_ROOT}/system/my_stock/app/Via"

echo "=== 4. Running All Offset-Verified AArch64 ELF Binary Patchers ==="
python3 "${M01}/scripts/patch_surfaceflinger_renderintent.py" -i "${ROM_ROOT}/system/system/bin/surfaceflinger" -o "${ROM_ROOT}/system/system/bin/surfaceflinger"
python3 "${M01}/scripts/patch_color_mode_sync.py"             -i "${ROM_ROOT}/odm/bin/hw/oplus-color-mode-sync" -o "${ROM_ROOT}/odm/bin/hw/oplus-color-mode-sync"
python3 "${M01}/scripts/patch_sensors_qsh_cct.py"             -i "${ROM_ROOT}/vendor/lib64/sensors.qsh.so" -o "${ROM_ROOT}/vendor/lib64/sensors.qsh.so"
python3 "${M01}/scripts/patch_libopex.py"                     -i "${ROM_ROOT}/system_ext/lib64/libopex.so" -o "${ROM_ROOT}/system_ext/lib64/libopex.so"
python3 "${M01}/scripts/patch_pass2_culprits.py" \
  --libcameraopt    "${ROM_ROOT}/vendor/lib64/libcameraopt.so" \
  --citsensor       "${ROM_ROOT}/odm/bin/hw/vendor.xiaomi.sensor.citsensorservice.aidl" \
  --libatlasservice "${ROM_ROOT}/system_ext/lib64/libatlasservice.so" \
  --horae           "${ROM_ROOT}/system_ext/bin/horae" \
  --out-dir         "${ROM_ROOT}/.tmp_pass2"
cp -f "${ROM_ROOT}/.tmp_pass2/libcameraopt.so" "${ROM_ROOT}/vendor/lib64/libcameraopt.so"
cp -f "${ROM_ROOT}/.tmp_pass2/vendor.xiaomi.sensor.citsensorservice.aidl" "${ROM_ROOT}/odm/bin/hw/vendor.xiaomi.sensor.citsensorservice.aidl"
cp -f "${ROM_ROOT}/.tmp_pass2/libatlasservice.so" "${ROM_ROOT}/system_ext/lib64/libatlasservice.so"
cp -f "${ROM_ROOT}/.tmp_pass2/horae" "${ROM_ROOT}/system_ext/bin/horae"
rm -rf "${ROM_ROOT}/.tmp_pass2"

python3 "${REPO_ROOT}/modules/05-display-hdr-color-and-haptics/display-hdr/scripts/patch_displayfeature_and_sdm.py" \
  --displayfeature "${ROM_ROOT}/odm/lib64/hw/displayfeature.default.so" \
  --sdmextension   "${ROM_ROOT}/vendor/lib64/libsdmextension.so" \
  --out-dir        "${ROM_ROOT}/.tmp_disp"
cp -f "${ROM_ROOT}/.tmp_disp/displayfeature.default.so" "${ROM_ROOT}/odm/lib64/hw/displayfeature.default.so"
cp -f "${ROM_ROOT}/.tmp_disp/libsdmextension.so" "${ROM_ROOT}/vendor/lib64/libsdmextension.so"
rm -rf "${ROM_ROOT}/.tmp_disp"

python3 "${REPO_ROOT}/modules/05-display-hdr-color-and-haptics/haptics/scripts/patch_vib_binaries.py" \
  --vibhal    "${ROM_ROOT}/odm/bin/hw/vendor.xiaomi.hardware.vibratorfeature.service" \
  --oplus-vib "${ROM_ROOT}/odm/bin/hw/vendor.oplus.hardware.vibrator-service" \
  --out-dir   "${ROM_ROOT}/.tmp_vib"
cp -f "${ROM_ROOT}/.tmp_vib/vendor.xiaomi.hardware.vibratorfeature.service" "${ROM_ROOT}/odm/bin/hw/vendor.xiaomi.hardware.vibratorfeature.service"
cp -f "${ROM_ROOT}/.tmp_vib/vendor.oplus.hardware.vibrator-service" "${ROM_ROOT}/odm/bin/hw/vendor.oplus.hardware.vibrator-service"
rm -rf "${ROM_ROOT}/.tmp_vib"

python3 "${REPO_ROOT}/modules/07-gallery-editor-and-opex/gallery-editor/scripts/patch_gallery_3base_libs.py" \
  --mseffect   "${ROM_ROOT}/system/my_product/lib64/libMsEffectSdk.so" \
  --aps-myprod "${ROM_ROOT}/system/my_product/lib64/libAPSClient-cmd-jni.so" \
  --aps-sysext "${ROM_ROOT}/system_ext/lib64/libAPSClient-cmd-jni-extension.oplus.so" \
  --out-dir    "${ROM_ROOT}/.tmp_gal"
cp -f "${ROM_ROOT}/.tmp_gal/my_product_libMsEffectSdk.so" "${ROM_ROOT}/system/my_product/lib64/libMsEffectSdk.so"
cp -f "${ROM_ROOT}/.tmp_gal/my_product_libAPSClient-cmd-jni.so" "${ROM_ROOT}/system/my_product/lib64/libAPSClient-cmd-jni.so"
cp -f "${ROM_ROOT}/.tmp_gal/system_ext_libAPSClient-cmd-jni-extension.oplus.so" "${ROM_ROOT}/system_ext/lib64/libAPSClient-cmd-jni-extension.oplus.so"
rm -rf "${ROM_ROOT}/.tmp_gal"

if [[ "$SKIP_RELEASE_ASSETS" -eq 0 ]]; then
  echo "=== 5. Fetching 5 >100 MB GitHub Release Assets ==="
  bash "${REPO_ROOT}/scripts/fetch_release_assets.sh" --rom-root "$ROM_ROOT"
fi

echo ""
echo "========================================================================="
echo "Automated file/config/binary integration complete!"
echo "Remaining manual/build steps (see README.md for exact commands):"
echo "  1. Merge SELinux CIL snippets (Module 01 + Module 02) into plat_sepolicy*.cil & run secilc -N"
echo "  2. Apply smali patches (services.jar, oplus-services.jar, telephony-common.jar,"
echo "     oplus-telephony-common.jar, ims-ext-common.jar, SystemUI, Settings, TeleService, Wallpapers, MiuiCamera)"
echo "     and build n3-runtime-v2.jar (python3 modules/02-esim-compat/scripts/build_java.py)"
echo "  3. Inject DT_NEEDED for MiuiCamera shims (patch_elf_needed.py)"
echo "  4. Re-sign modified APKs with your keys: bash signing/sign_rom_apks.sh --rom-root ${ROM_ROOT}"
echo "  5. Fetch pre-signed Titanium Browser (DO NOT re-sign!):"
echo "     bash modules/09-apps-and-ui/titanium-browser/fetch_titanium_browser.sh --out ${ROM_ROOT}/product/app/TitaniumBrowser/TitaniumBrowser.apk"
echo "========================================================================="
