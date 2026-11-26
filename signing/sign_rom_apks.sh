#!/usr/bin/env bash
# Automatically align (-P 16 -f 4) and v1+v2+v3 sign all modified system APKs inside an
# unpacked ColorOS 17 ROM tree using the user's locally generated keys in signing/keys/.
#
# IMPORTANT:
#   - Explicitly SKIPS TitaniumBrowser.apk (MUST remain signed by upstream
#     ampereforest/android-titanium-browser so standalone APK updates work without reflashing!).
#   - Explicitly SKIPS untouched OEM/Google APKs (OplusLauncher, OcrScanner, BaseOcrScanner,
#     Gemini, LatinImeGoogle, VelvetCtS, OpenAlive).
#
# Usage:
#   bash signing/sign_rom_apks.sh --rom-root /path/to/unpacked_rom
#   ANDROID_BUILD_TOOLS=/path/to/build-tools/37.0.0 bash signing/sign_rom_apks.sh --rom-root /path/to/unpacked_rom
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KEYS_DIR="${SCRIPT_DIR}/keys"
ROM_ROOT=""
DRY_RUN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --rom-root) ROM_ROOT="$2"; shift 2 ;;
    --keys-dir) KEYS_DIR="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help)
      echo "Usage: $0 --rom-root /path/to/unpacked_rom [--keys-dir signing/keys] [--dry-run]"
      exit 0
      ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$ROM_ROOT" || ! -d "$ROM_ROOT" ]]; then
  echo "ERROR: Pass --rom-root pointing to your unpacked ROM directory." >&2
  exit 1
fi

if [[ -n "${ANDROID_BUILD_TOOLS:-}" ]]; then
  PATH="${ANDROID_BUILD_TOOLS}:${PATH}"
fi

for tool in zipalign apksigner; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "ERROR: '$tool' not found in PATH (set ANDROID_BUILD_TOOLS=/path/to/android-sdk/build-tools/37.0.0)." >&2
    exit 1
  fi
done

PLAT_P12="${KEYS_DIR}/platform.p12"
ESIM_P12="${KEYS_DIR}/esim-release.p12"
PASS_FILE="${KEYS_DIR}/keystore.pass"

if [[ ! -f "$PLAT_P12" || ! -f "$PASS_FILE" ]]; then
  echo "ERROR: Missing ${PLAT_P12} or ${PASS_FILE}. Run 'bash signing/generate_keys.sh' first." >&2
  exit 1
fi
if [[ ! -f "$ESIM_P12" ]]; then
  echo "[INFO] ${ESIM_P12} not found; falling back to ${PLAT_P12} for OpenEUICC & DadaEsimUI."
  ESIM_P12="$PLAT_P12"
  ESIM_ALIAS="platform"
else
  ESIM_ALIAS="esim-release"
fi

sign_apk() {
  local rel="$1"
  local ks="$2"
  local alias="$3"

  # Support both unpacked super layout (system/my_product/...) and flat layout (my_product/...)
  local target="${ROM_ROOT}/${rel}"
  if [[ ! -f "$target" && "$rel" == my_* ]]; then
    target="${ROM_ROOT}/system/${rel}"
  fi
  if [[ ! -f "$target" ]]; then
    echo "[SKIP] Not present: ${rel}"
    return 0
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[DRY ] Would align & sign ${target} with alias=${alias}"
    return 0
  fi

  local tmp_aligned="${target}.aligned.tmp"
  local tmp_signed="${target}.signed.tmp"
  zipalign -P 16 -f 4 "$target" "$tmp_aligned"
  apksigner sign \
    --ks "$ks" \
    --ks-type PKCS12 \
    --ks-key-alias "$alias" \
    --ks-pass "file:${PASS_FILE}" \
    --v1-signing-enabled true \
    --v2-signing-enabled true \
    --v3-signing-enabled true \
    --v4-signing-enabled false \
    --out "$tmp_signed" \
    "$tmp_aligned"
  apksigner verify --verbose "$tmp_signed" >/dev/null
  mv -f "$tmp_signed" "$target"
  rm -f "$tmp_aligned" "${tmp_signed}.idsig"
  echo "[OK  ] Signed (${alias}): ${rel}"
}

echo "=== Signing Modified Platform / System APKs (key: platform) ==="
PLATFORM_APKS=(
  "system_ext/priv-app/SystemUI/SystemUI.apk"
  "system_ext/priv-app/Settings/Settings.apk"
  "system_ext/priv-app/TeleService/TeleService.apk"
  "my_stock/priv-app/Wallpapers/Wallpapers.apk"
  "my_product/overlay/aon.frameworkres.overlay.product.apk"
  "product/priv-app/MiuiCamera/MiuiCamera.apk"
  "my_product/app/OplusCamera/OplusCamera.apk"
  "product/priv-app/DadaAngleUI/DadaAngleUI.apk"
)
for rel in "${PLATFORM_APKS[@]}"; do
  sign_apk "$rel" "$PLAT_P12" "platform"
done

echo ""
echo "=== Signing eSIM Bridge Pair (key: ${ESIM_ALIAS}) ==="
ESIM_APKS=(
  "product/priv-app/OpenEUICC/OpenEUICC.apk"
  "product/priv-app/DadaEsimUI/DadaEsimUI.apk"
)
for rel in "${ESIM_APKS[@]}"; do
  sign_apk "$rel" "$ESIM_P12" "$ESIM_ALIAS"
done

echo ""
echo "[NOTE] TitaniumBrowser.apk was intentionally NOT re-signed so standalone updates"
echo "       from https://github.com/ampereforest/android-titanium-browser/releases/latest work cleanly."
