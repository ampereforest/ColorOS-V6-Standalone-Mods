#!/usr/bin/env python3
"""
Automatically reads the user's locally generated certificates in signing/keys/ and stamps
their SHA-256 digests into:
  1. modules/02-esim-compat/patches/services-platform-signer-compat.patch
     (PackageManagerServiceUtils.isDadaPlatformCompat & isDadaSigner — uses platform.x509.pem)
  2. modules/02-esim-compat/integration/owner/org/sourceowned/n3/runtime/v2/CallerPolicy.java
     (CERT_SHA256 — uses esim-release.x509.pem, falling back to platform.x509.pem)

Usage:
    python3 signing/render_framework_signer.py
    python3 signing/render_framework_signer.py \
        --platform-cert signing/keys/platform.x509.pem \
        --esim-cert signing/keys/esim-release.x509.pem
"""

import argparse
import hashlib
import re
import subprocess
import sys
from pathlib import Path


def cert_to_sha256(cert_path: Path) -> str:
    if not cert_path.exists():
        sys.exit(f"ERROR: Certificate not found: {cert_path}\nRun 'bash signing/generate_keys.sh' first.")
    raw = cert_path.read_bytes()
    if b"BEGIN CERTIFICATE" in raw:
        der = subprocess.check_output(["openssl", "x509", "-in", str(cert_path), "-outform", "DER"])
    else:
        der = raw
    return hashlib.sha256(der).hexdigest()


def hex_to_smali_array_lines(hex_str: str, indent: str = "+        ") -> str:
    bs = bytes.fromhex(hex_str)
    assert len(bs) == 32
    lines = []
    for b in bs:
        signed = b - 256 if b >= 128 else b
        lines.append(f"{indent}-0x{-signed:x}t" if signed < 0 else f"{indent}0x{signed:x}t")
    return "\n".join(lines)


def main() -> int:
    repo = Path(__file__).resolve().parent.parent
    keys_dir = repo / "signing/keys"

    ap = argparse.ArgumentParser(description="Stamp generated signing/keys/ certificates into ROM patches")
    ap.add_argument("--platform-cert", type=Path, default=keys_dir / "platform.x509.pem",
                    help="Platform X.509 cert (.pem/.der) used to sign modified SystemUI/Settings/TeleService/etc.")
    ap.add_argument("--esim-cert", type=Path, default=keys_dir / "esim-release.x509.pem",
                    help="eSIM X.509 cert (.pem/.der) used to sign OpenEUICC & DadaEsimUI (falls back to platform-cert)")
    args = ap.parse_args()

    plat_sha = cert_to_sha256(args.platform_cert)
    esim_cert = args.esim_cert if args.esim_cert.exists() else args.platform_cert
    esim_sha = cert_to_sha256(esim_cert)

    # 1. Patch services-platform-signer-compat.patch (:array_2e in isDadaPlatformCompat, :array_10 in isDadaSigner)
    pmsu_patch = repo / "modules/02-esim-compat/patches/services-platform-signer-compat.patch"
    if not pmsu_patch.exists():
        sys.exit(f"ERROR: Missing patch file: {pmsu_patch}")
    ptxt = pmsu_patch.read_text()
    new_block = hex_to_smali_array_lines(plat_sha)

    def repl_array(m):
        return m.group(1) + "\n" + new_block + "\n" + m.group(2)

    ptxt_new, count = re.subn(
        r"(\+\s*:array_(?:2e|10)\n\+\s*\.array-data 1)\n(?:\+\s*-?0x[0-9a-f]+t\n){32}(\+\s*\.end array-data)",
        repl_array,
        ptxt,
    )
    if count != 2:
        sys.exit(f"ERROR: Expected 2 custom signer byte arrays (:array_2e & :array_10) in {pmsu_patch}, found {count}.")
    pmsu_patch.write_text(ptxt_new)
    print(f"[OK] Stamped platform cert SHA-256 ({plat_sha}) -> {pmsu_patch.relative_to(repo)}")

    # 2. Patch CallerPolicy.java (for n3-runtime-v2.jar)
    caller_policy = repo / "modules/02-esim-compat/integration/owner/org/sourceowned/n3/runtime/v2/CallerPolicy.java"
    if not caller_policy.exists():
        sys.exit(f"ERROR: Missing file: {caller_policy}")
    ctxt = caller_policy.read_text()
    ctxt_new, ccount = re.subn(
        r'public static final String CERT_SHA256 = "[0-9a-fA-F]{64}";',
        f'public static final String CERT_SHA256 = "{esim_sha}";',
        ctxt,
    )
    if ccount != 1:
        sys.exit(f"ERROR: Expected 1 CERT_SHA256 declaration in {caller_policy}, found {ccount}.")
    caller_policy.write_text(ctxt_new)
    print(f"[OK] Stamped eSIM cert SHA-256     ({esim_sha}) -> {caller_policy.relative_to(repo)}")

    print("\nAll framework & eSIM signer patches are now bound to your local signing/keys/ certificates.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
