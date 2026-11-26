#!/usr/bin/env bash
# Fetch the latest pre-signed Titanium Browser APK directly from upstream:
#   https://github.com/ampereforest/android-titanium-browser/releases/latest
#
# CRITICAL: DO NOT patch or re-sign TitaniumBrowser.apk with your ROM signing keys!
# Keeping the upstream release signature allows users to install future standalone
# Titanium Browser APK updates directly without reflashing the ROM.
#
# Usage:
#   bash modules/09-apps-and-ui/titanium-browser/fetch_titanium_browser.sh
#   bash modules/09-apps-and-ui/titanium-browser/fetch_titanium_browser.sh --out /path/to/rom/product/app/TitaniumBrowser/TitaniumBrowser.apk
set -euo pipefail

OUT_APK="./TitaniumBrowser.apk"
REPO="ampereforest/android-titanium-browser"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --out|-o) OUT_APK="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: $0 [--out /path/to/product/app/TitaniumBrowser/TitaniumBrowser.apk]"
      exit 0
      ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

mkdir -p "$(dirname "$OUT_APK")"

echo "Querying latest release from https://github.com/${REPO}/releases/latest ..."
API_URL="https://api.github.com/repos/${REPO}/releases/latest"

ASSET_URL="$(python3 - "$API_URL" << 'PY'
import json, sys, urllib.request
req = urllib.request.Request(sys.argv[1], headers={"Accept": "application/vnd.github+json", "User-Agent": "ColorOS-V6-Standalone-Mods"})
with urllib.request.urlopen(req, timeout=30) as resp:
    rel = json.loads(resp.read().decode("utf-8"))
apks = [a for a in rel.get("assets", []) if a["name"].endswith(".apk")]
# Prefer arm64 APK if multiple ABI builds exist
arm64 = [a for a in apks if "arm64" in a["name"].lower()]
chosen = (arm64 or apks)
if not chosen:
    sys.exit("ERROR: No .apk asset found in latest release of ampereforest/android-titanium-browser.")
print(f"{rel.get('tag_name','latest')}\t{chosen[0]['name']}\t{chosen[0]['browser_download_url']}")
PY
)"

TAG="$(printf '%s' "$ASSET_URL" | cut -f1)"
NAME="$(printf '%s' "$ASSET_URL" | cut -f2)"
URL="$(printf '%s' "$ASSET_URL" | cut -f3)"

echo "Downloading ${NAME} (${TAG}) -> ${OUT_APK} ..."
curl -fL --progress-bar -o "${OUT_APK}.tmp" "$URL"
mv -f "${OUT_APK}.tmp" "$OUT_APK"
chmod 0644 "$OUT_APK"

echo "[OK] Downloaded pre-signed Titanium Browser (${TAG}): ${OUT_APK}"
echo "     SHA-256: $(sha256sum "$OUT_APK" | awk '{print $1}')"
echo "     Reminder: Do NOT re-sign this APK. Install as /product/app/TitaniumBrowser/TitaniumBrowser.apk (0644)."
