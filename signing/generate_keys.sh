#!/usr/bin/env bash
# Generate local Android platform/media/shared/releasekey & eSIM signing certificates
# into signing/keys/ (gitignored).
#
# Usage:
#   bash signing/generate_keys.sh
#   bash signing/generate_keys.sh --non-interactive --subject "/C=US/O=MyROM/CN=MyROM" --password "changeit"
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KEYS_DIR="${SCRIPT_DIR}/keys"
SUBJECT="/C=US/ST=Local/L=Local/O=ColorOS17Mod/OU=Android/CN=ColorOS17Mod"
PASSWORD=""
NON_INTERACTIVE=0
FORCE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --subject) SUBJECT="$2"; shift 2 ;;
    --password) PASSWORD="$2"; shift 2 ;;
    --non-interactive) NON_INTERACTIVE=1; shift ;;
    --force) FORCE=1; shift ;;
    -h|--help)
      echo "Usage: $0 [--subject '/C=.../CN=...'] [--password PASS] [--non-interactive] [--force]"
      exit 0
      ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

for tool in openssl keytool; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "ERROR: Required tool '$tool' not found in PATH." >&2
    exit 1
  fi
done

mkdir -p "$KEYS_DIR"
chmod 0700 "$KEYS_DIR"

if [[ -z "$PASSWORD" ]]; then
  if [[ "$NON_INTERACTIVE" -eq 1 ]]; then
    PASSWORD="$(openssl rand -hex 24)"
    echo "Generated random PKCS#12 keystore password saved to ${KEYS_DIR}/keystore.pass (chmod 0600)."
  else
    read -r -s -p "Enter keystore password for PKCS#12 bundles (min 6 chars): " PASSWORD
    echo
    if [[ ${#PASSWORD} -lt 6 ]]; then
      echo "ERROR: Password must be at least 6 characters." >&2
      exit 1
    fi
  fi
fi

PASS_FILE="${KEYS_DIR}/keystore.pass"
umask 077
printf '%s\n' "$PASSWORD" > "$PASS_FILE"
chmod 0600 "$PASS_FILE"

generate_one() {
  local name="$1"
  local cn_suffix="$2"
  local pem="${KEYS_DIR}/${name}.x509.pem"
  local pk8="${KEYS_DIR}/${name}.pk8"
  local p12="${KEYS_DIR}/${name}.p12"
  local key_tmp="${KEYS_DIR}/.${name}.key.tmp"

  if [[ -f "$p12" && "$FORCE" -ne 1 ]]; then
    echo "[SKIP] ${name} already exists in ${KEYS_DIR} (pass --force to overwrite)."
    return 0
  fi

  echo "[GEN ] ${name} (RSA-4096, 10000 days)..."
  openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:4096 -out "$key_tmp" 2>/dev/null
  openssl req -new -x509 -sha256 -days 10000 \
    -key "$key_tmp" \
    -subj "${SUBJECT}-${cn_suffix}" \
    -out "$pem"
  openssl pkcs8 -topk8 -outform DER -nocrypt -in "$key_tmp" -out "$pk8"
  openssl pkcs12 -export \
    -in "$pem" -inkey "$key_tmp" \
    -name "$name" \
    -passout "file:${PASS_FILE}" \
    -out "$p12"
  rm -f "$key_tmp"
  chmod 0600 "$pk8" "$p12"
  chmod 0644 "$pem"
}

generate_one "platform"     "Platform"
generate_one "media"        "Media"
generate_one "shared"       "Shared"
generate_one "releasekey"   "ReleaseKey"
generate_one "esim-release" "EsimRelease"

SHA_OUT="${KEYS_DIR}/CERT_SHA256.txt"
: > "$SHA_OUT"
echo ""
echo "=== Generated Signing Certificates (SHA-256) ==="
for name in platform media shared releasekey esim-release; do
  pem="${KEYS_DIR}/${name}.x509.pem"
  sha="$(openssl x509 -in "$pem" -outform DER | sha256sum | awk '{print $1}')"
  printf '%-14s %s\n' "$name" "$sha" | tee -a "$SHA_OUT"
done
chmod 0644 "$SHA_OUT"

echo ""
echo "Keys saved under: ${KEYS_DIR}/"
echo "Next step: run 'python3 signing/render_framework_signer.py' to stamp your"
echo "certificate SHA-256 into services.jar & eSIM CallerPolicy.java patches."
