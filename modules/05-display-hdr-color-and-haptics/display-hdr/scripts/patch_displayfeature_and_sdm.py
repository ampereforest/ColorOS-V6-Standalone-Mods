#!/usr/bin/env python3
"""
Offset-verified AArch64 ELF patcher for Xiaomi 15 (dada) ColorOS 17 HDR / Color Mode display HALs:
  1. odm/lib64/hw/displayfeature.default.so (5 instructions -> 3200-nit HDR / HBM bring-up)
  2. vendor/lib64/libsdmextension.so        (1 instruction  -> HDR blending space / ColorMode fix)

Usage:
    python3 patch_displayfeature_and_sdm.py \
        --displayfeature odm/lib64/hw/displayfeature.default.so \
        --sdmextension   vendor/lib64/libsdmextension.so \
        --out-dir        ./out
    python3 patch_displayfeature_and_sdm.py --verify-only --displayfeature ... --sdmextension ...
"""

import argparse
import hashlib
import sys
from pathlib import Path

PATCHES = {
    "displayfeature": {
        "expected_size": 397936,
        "expected_base_md5": "1667550fdf09518c66bf90fc85a925ca",
        "expected_final_md5": "5f6522e07eaa6a1114a07a2273cf741e",
        "filename": "displayfeature.default.so",
        "edits": [
            (0x2E660, bytes.fromhex("68010034"), bytes.fromhex("1f2003d5")),  # cbz -> nop
            (0x2E67C, bytes.fromhex("80000036"), bytes.fromhex("1f2003d5")),  # tbz -> nop
            (0x4806C, bytes.fromhex("68010034"), bytes.fromhex("1f2003d5")),  # cbz -> nop
            (0x48088, bytes.fromhex("80000036"), bytes.fromhex("1f2003d5")),  # tbz -> nop
            (0x4ED3C, bytes.fromhex("2bf6ff54"), bytes.fromhex("18000014")),  # b.lt -> b +0x60
        ],
    },
    "sdmextension": {
        "expected_size": 2312408,
        "expected_base_md5": "f1708720e21807cf6e9e04dfe58c7ab1",
        "expected_final_md5": "dcf49b7a829db7817028df9488e6ed11",
        "filename": "libsdmextension.so",
        "edits": [
            (0x1430E0, bytes.fromhex("e9f8ff34"), bytes.fromhex("1f2003d5")),  # cbz w9 -> nop
        ],
    },
}


def patch_one(spec: dict, inp: Path, out_dir: Path | None, verify_only: bool) -> None:
    raw = inp.read_bytes()
    if raw[:4] != b"\x7fELF":
        sys.exit(f"ERROR: {inp} is not an ELF binary.")
    if len(raw) != spec["expected_size"]:
        sys.exit(f"ERROR: {inp} size {len(raw)} != expected {spec['expected_size']}")
    md5 = hashlib.md5(raw).hexdigest()
    if md5 == spec["expected_final_md5"]:
        print(f"[SKIP] {inp} is already patched (MD5={md5}).")
        return
    if md5 != spec["expected_base_md5"]:
        sys.exit(f"ERROR: {inp} MD5 {md5} != expected base {spec['expected_base_md5']}")
    buf = bytearray(raw)
    for off, orig, repl in spec["edits"]:
        got = bytes(buf[off : off + len(orig)])
        if got != orig:
            sys.exit(f"ERROR: {inp}@{hex(off)} got {got.hex()} != expected {orig.hex()}")
        buf[off : off + len(repl)] = repl
    out_md5 = hashlib.md5(buf).hexdigest()
    assert out_md5 == spec["expected_final_md5"], f"Post-patch MD5 mismatch: {out_md5}"
    if verify_only:
        print(f"[OK  ] Verified {inp} -> target MD5 {out_md5}")
        return
    out_dir.mkdir(parents=True, exist_ok=True)
    dst = out_dir / spec["filename"]
    dst.write_bytes(buf)
    print(f"[OK  ] Wrote {dst} (MD5={out_md5})")


def main() -> int:
    ap = argparse.ArgumentParser(description="Patch displayfeature.default.so & libsdmextension.so for Xiaomi 15 ColorOS 17 HDR")
    ap.add_argument("--displayfeature", type=Path, help="Input odm/lib64/hw/displayfeature.default.so")
    ap.add_argument("--sdmextension", type=Path, help="Input vendor/lib64/libsdmextension.so")
    ap.add_argument("--out-dir", type=Path, default=Path("./out"), help="Output directory")
    ap.add_argument("--verify-only", action="store_true", help="Verify offsets without writing output")
    args = ap.parse_args()

    if not args.displayfeature and not args.sdmextension:
        sys.exit("ERROR: Provide --displayfeature and/or --sdmextension.")
    if args.displayfeature:
        patch_one(PATCHES["displayfeature"], args.displayfeature, args.out_dir, args.verify_only)
    if args.sdmextension:
        patch_one(PATCHES["sdmextension"], args.sdmextension, args.out_dir, args.verify_only)
    return 0


if __name__ == "__main__":
    sys.exit(main())
