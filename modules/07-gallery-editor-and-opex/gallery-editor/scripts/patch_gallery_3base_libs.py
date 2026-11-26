#!/usr/bin/env python3
"""
Offset-verified AArch64 ELF patcher fixing ColorOS 17 Gallery Editor (PhotoEditorActivity)
instant native SIGSEGV crashes on base V6 libraries:
  1. my_product/lib64/libMsEffectSdk.so
     Zeroes 14 uninitialized .data mIs* flags at 0x5ba30 (avoids dlopen crash on absent libmsnativefilter.so)
  2. my_product/lib64/libAPSClient-cmd-jni.so
     NOPs two unchecked `blr x8` calls (0x778c0, 0x778d0) in APSClient_createClient
  3. system_ext/lib64/libAPSClient-cmd-jni-extension.oplus.so
     NOPs two unchecked `blr x8` calls (0x77844, 0x77854) in APSClient_createClient

Note: The two additional PMX110 libraries placed in product/lib64/ (libMsEffectSdk.so and
libAPSClient-cmd-jni.so) inside modules/04-camera-oplus-experimental/product/lib64/ are
already pre-patched (MD5 ab1d8e94... and 001292d7...) to cover all 5 affected libraries.

Usage:
    python3 patch_gallery_3base_libs.py \
        --mseffect    my_product/lib64/libMsEffectSdk.so \
        --aps-myprod  my_product/lib64/libAPSClient-cmd-jni.so \
        --aps-sysext  system_ext/lib64/libAPSClient-cmd-jni-extension.oplus.so \
        --out-dir     ./out
"""

import argparse
import hashlib
import sys
from pathlib import Path

SPECS = {
    "mseffect": {
        "name": "my_product_libMsEffectSdk.so",
        "size": 377968,
        "base_md5": "01ffc9546ea77019f17d9e340a121948",
        "final_md5": "a649493ac9c9355ed573d115289b4245",
        "edits": [
            (0x5BA30, b"\x01" * 14, b"\x00" * 14),
        ],
    },
    "aps_myprod": {
        "name": "my_product_libAPSClient-cmd-jni.so",
        "size": 1115608,
        "base_md5": "f190f65d3256adfccd331eb1ef9b37a6",
        "final_md5": "5ca28b8ee8b0f655e8b9a2b058c79114",
        "edits": [
            (0x778C0, bytes.fromhex("00013fd6"), bytes.fromhex("1f2003d5")),  # blr x8 -> nop
            (0x778D0, bytes.fromhex("00013fd6"), bytes.fromhex("1f2003d5")),  # blr x8 -> nop
        ],
    },
    "aps_sysext": {
        "name": "system_ext_libAPSClient-cmd-jni-extension.oplus.so",
        "size": 1099512,
        "base_md5": "68b7bdd07f0a1e3401ec8048d94481ae",
        "final_md5": "55e8deb39ab9f2a050bb05affbffc071",
        "edits": [
            (0x77844, bytes.fromhex("00013fd6"), bytes.fromhex("1f2003d5")),  # blr x8 -> nop
            (0x77854, bytes.fromhex("00013fd6"), bytes.fromhex("1f2003d5")),  # blr x8 -> nop
        ],
    },
}


def apply_one(spec: dict, inp: Path, out_dir: Path, verify_only: bool) -> None:
    raw = inp.read_bytes()
    if len(raw) != spec["size"]:
        sys.exit(f"ERROR: {inp} size {len(raw)} != expected {spec['size']}")
    md5 = hashlib.md5(raw).hexdigest()
    if md5 == spec["final_md5"]:
        print(f"[SKIP] {inp} is already patched (MD5={md5}).")
        return
    if md5 != spec["base_md5"]:
        sys.exit(f"ERROR: {inp} MD5 {md5} != expected base {spec['base_md5']}")
    buf = bytearray(raw)
    for off, orig, repl in spec["edits"]:
        got = bytes(buf[off : off + len(orig)])
        if got != orig:
            sys.exit(f"ERROR: {inp}@{hex(off)} got {got.hex()} != expected {orig.hex()}")
        buf[off : off + len(repl)] = repl
    out_md5 = hashlib.md5(buf).hexdigest()
    assert out_md5 == spec["final_md5"], f"Post-patch MD5 mismatch: {out_md5}"
    if verify_only:
        print(f"[OK  ] Verified {inp} -> MD5={out_md5}")
        return
    out_dir.mkdir(parents=True, exist_ok=True)
    dst = out_dir / spec["name"]
    dst.write_bytes(buf)
    print(f"[OK  ] Wrote {dst} (MD5={out_md5})")


def main() -> int:
    ap = argparse.ArgumentParser(description="Fix ColorOS 17 Gallery Editor SIGSEGV across base V6 libraries")
    ap.add_argument("--mseffect", type=Path, help="Input my_product/lib64/libMsEffectSdk.so")
    ap.add_argument("--aps-myprod", type=Path, help="Input my_product/lib64/libAPSClient-cmd-jni.so")
    ap.add_argument("--aps-sysext", type=Path, help="Input system_ext/lib64/libAPSClient-cmd-jni-extension.oplus.so")
    ap.add_argument("--out-dir", type=Path, default=Path("./out"), help="Output directory")
    ap.add_argument("--verify-only", action="store_true", help="Verify offsets without writing output")
    args = ap.parse_args()

    if not any((args.mseffect, args.aps_myprod, args.aps_sysext)):
        sys.exit("ERROR: Provide at least one of --mseffect, --aps-myprod, --aps-sysext.")
    if args.mseffect:
        apply_one(SPECS["mseffect"], args.mseffect, args.out_dir, args.verify_only)
    if args.aps_myprod:
        apply_one(SPECS["aps_myprod"], args.aps_myprod, args.out_dir, args.verify_only)
    if args.aps_sysext:
        apply_one(SPECS["aps_sysext"], args.aps_sysext, args.out_dir, args.verify_only)
    return 0


if __name__ == "__main__":
    sys.exit(main())
