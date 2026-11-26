#!/usr/bin/env bash
# Download all 5 >100 MB non-V6 ROM assets from GitHub Releases on
# ampereforest/ColorOS-V6-Standalone-Mods (tag: v7.3.1-assets), verify SHA-256,
# and place them into their exact modular destinations.
#
# Usage:
#   bash scripts/fetch_release_assets.sh
#   bash scripts/fetch_release_assets.sh --rom-root /path/to/unpacked_rom
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
REPO="ampereforest/ColorOS-V6-Standalone-Mods"
TAG="v7.3.1-assets"
ROM_ROOT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --rom-root) ROM_ROOT="$2"; shift 2 ;;
    --tag) TAG="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: $0 [--rom-root /path/to/unpacked_rom] [--tag v7.3.1-assets]"
      exit 0
      ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

BASE_URL="https://github.com/${REPO}/releases/download/${TAG}"
SHA_FILE="${SCRIPT_DIR}/RELEASE_ASSETS.sha256"

if [[ ! -f "$SHA_FILE" ]]; then
  echo "ERROR: Missing ${SHA_FILE}" >&2
  exit 1
fi

fetch_one() {
  local asset_name="$1"
  local rel_dest="$2"
  local rom_dest="$3"
  local expected_sha
  expected_sha="$(awk -v f="$asset_name" '$2 == f {print $1}' "$SHA_FILE")"
  if [[ -z "$expected_sha" ]]; then
    echo "ERROR: No SHA-256 entry for ${asset_name} in ${SHA_FILE}" >&2
    exit 1
  fi

  local dst
  if [[ -n "$ROM_ROOT" ]]; then
    dst="${ROM_ROOT}/${rom_dest}"
  else
    dst="${REPO_ROOT}/${rel_dest}"
  fi
  mkdir -p "$(dirname "$dst")"

  if [[ -f "$dst" ]]; then
    local cur_sha
    cur_sha="$(sha256sum "$dst" | awk '{print $1}')"
    if [[ "$cur_sha" == "$expected_sha" ]]; then
      echo "[OK  ] Already present & verified: ${dst}"
      return 0
    fi
    echo "[WARN] Checksum mismatch on ${dst}; re-downloading..."
  fi

  echo "[GET ] ${BASE_URL}/${asset_name} -> ${dst}"
  curl -fL --progress-bar -o "${dst}.tmp" "${BASE_URL}/${asset_name}"
  local dl_sha
  dl_sha="$(sha256sum "${dst}.tmp" | awk '{print $1}')"
  if [[ "$dl_sha" != "$expected_sha" ]]; then
    rm -f "${dst}.tmp"
    echo "ERROR: SHA-256 mismatch for ${asset_name}: got ${dl_sha}, expected ${expected_sha}" >&2
    exit 1
  fi
  mv -f "${dst}.tmp" "$dst"
  chmod 0644 "$dst"
  echo "[OK  ] Verified SHA-256: ${dst}"
}

fetch_one "OpenAlive-v0.4.43-en-rootless.apk" \
  "modules/09-apps-and-ui/openalive-wallpaper/product/app/OpenAlive/OpenAlive.apk" \
  "product/app/OpenAlive/OpenAlive.apk"

fetch_one "VelvetCtS-17.46.15-arm64.apk" \
  "modules/09-apps-and-ui/google-suite/product/priv-app/VelvetCtS/VelvetCtS.apk" \
  "product/priv-app/VelvetCtS/VelvetCtS.apk"

fetch_one "OplusCamera-7.013.40-dada-wip.apk" \
  "modules/04-camera-oplus-experimental/my_product/app/OplusCamera/OplusCamera.apk" \
  "system/my_product/app/OplusCamera/OplusCamera.apk"

fetch_one "OcrScanner-17.2.22-OP15-Global.apk" \
  "modules/09-apps-and-ui/osee-op15-global/my_stock/del-app/OcrScanner/OcrScanner.apk" \
  "system/my_stock/del-app/OcrScanner/OcrScanner.apk"

fetch_one "modemfirmware-dada-global-OS4.0.0.11.img" \
  "modules/10-modem-and-flashing/images/modemfirmware.img" \
  "images/modemfirmware.img"

echo ""
echo "All 5 large GitHub Release assets downloaded & SHA-256 verified!"
echo "For Titanium Browser (DO NOT re-sign!), run:"
echo "  bash modules/09-apps-and-ui/titanium-browser/fetch_titanium_browser.sh"
