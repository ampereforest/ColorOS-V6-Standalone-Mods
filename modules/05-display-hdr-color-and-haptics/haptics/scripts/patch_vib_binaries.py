#!/usr/bin/env python3
"""
Offset-verified AArch64 ELF binary patcher for Xiaomi 15 (dada) ColorOS 17 Adaptive Multi-Texture Haptics:
  1. odm/bin/hw/vendor.xiaomi.hardware.vibratorfeature.service:
     - NOP duplicate IVibrator/default addService (0x10854) so ColorOSVibBridge + xmvibproxy own IVibrator/default
     - Set slide_effect_protect_time = 0 (0x170f4) to eliminate rapid-typing stalls
     - NOP mid-playback setGain (0x162d0) to eliminate PMIC qcom-hv-haptics rc=-16 EBUSY faults
     - Route IVibrator::setAmplitude (0x1decc/0x1df5c) -> clamp >= 0.05f & store into BSS [0x3c01c]
     - Widen mi_f0_check==2 magnitude range [8191..32767] -> [3071..32767] (9.4%..100% Vmax)
  2. odm/bin/hw/vendor.oplus.hardware.vibrator-service:
     - Reorder Xiaomi::perform_with_amplitude (0x1a1a4) to call amplitude() BEFORE perform()
     - Replace Catalog::xiaomi_effect (0x19d4c + 0x50d0..0x5263) with 404-entry PCM-verified instant-onset
       (<= 2.1 ms) ColorOS waveform_id -> Xiaomi 15 /odm/firmware/*_P_RTP.bin lookup table

Usage:
    python3 patch_vib_binaries.py \
        --vibhal    odm/bin/hw/vendor.xiaomi.hardware.vibratorfeature.service \
        --oplus-vib odm/bin/hw/vendor.oplus.hardware.vibrator-service \
        --out-dir   ./out
"""

import argparse
import hashlib
import os
import struct
import sys
from pathlib import Path

EXPECTED_VIBHAL_FINAL_MD5 = "56e7363acb1e"
EXPECTED_OPLUS_FINAL_MD5 = "58c1f6b49613"


def parse_load_segs(data: bytes):
    e_phoff = struct.unpack_from("<Q", data, 32)[0]
    e_phentsize, e_phnum = struct.unpack_from("<HH", data, 54)
    segs = []
    for i in range(e_phnum):
        p_type, p_flags, p_offset, p_vaddr, p_paddr, p_filesz, p_memsz, p_align = struct.unpack_from(
            "<IIQQQQQQ", data, e_phoff + i * e_phentsize
        )
        if p_type == 1:
            segs.append((p_vaddr, p_vaddr + p_filesz, p_offset))
    return segs


def v2f(segs, va: int) -> int:
    for s, e, off in segs:
        if s <= va < e:
            return off + (va - s)
    raise ValueError(f"VA {hex(va)} not in PT_LOAD")


def enc_b(src: int, dst: int) -> int:
    diff = dst - src
    assert diff % 4 == 0
    return 0x14000000 | ((diff // 4) & 0x03FFFFFF)


def enc_bl(src: int, dst: int) -> int:
    diff = dst - src
    assert diff % 4 == 0
    return 0x94000000 | ((diff // 4) & 0x03FFFFFF)


def enc_adrp(pc: int, target_page: int, rd: int) -> int:
    diff_pages = (target_page - (pc & ~0xFFF)) >> 12
    return 0x90000000 | ((diff_pages & 0x3) << 29) | (((diff_pages >> 2) & 0x7FFFF) << 5) | rd


def patch_u32(buf: bytearray, segs, va: int, val: int):
    struct.pack_into("<I", buf, v2f(segs, va), val)


def build_waveform_table() -> bytes:
    tbl = [181] * 404
    explicit = {
        0: 181, 1: 166, 2: 88, 3: 173, 4: 4, 5: 162, 6: 188, 7: 178, 8: 181, 9: 5,
        10: 86, 11: 217, 12: 130, 13: 201, 14: 84, 15: 67, 16: 60,
        41: 205, 42: 67, 43: 164, 44: 171, 45: 60, 46: 1, 47: 172, 54: 201, 55: 205, 56: 5, 57: 3, 58: 5,
        60: 140, 61: 142, 62: 142, 63: 145, 64: 145, 65: 143, 66: 144, 67: 145, 68: 145, 69: 150,
        80: 60, 81: 205, 82: 55, 83: 206, 84: 67, 85: 167, 86: 171, 87: 164, 88: 208, 89: 207,
        96: 164, 97: 67, 98: 7, 100: 140, 101: 142, 102: 142, 103: 145, 104: 145,
        105: 201, 106: 202, 107: 203, 108: 211, 109: 210, 110: 178, 111: 181, 112: 4, 118: 205, 122: 167,
        123: 205, 125: 171, 126: 55, 127: 60, 128: 67, 129: 206, 130: 167, 131: 172, 132: 208, 133: 164,
        142: 178, 143: 181, 144: 178, 145: 6, 146: 7, 147: 8, 148: 9, 149: 166, 150: 167, 156: 168,
        170: 167, 171: 162, 172: 163, 173: 85, 174: 162, 175: 163, 176: 201, 177: 162, 178: 163, 179: 166,
        180: 88, 181: 205, 183: 202, 184: 185, 185: 167, 186: 4, 187: 201, 188: 163, 211: 211,
        237: 60, 238: 205, 239: 171, 240: 55, 241: 172, 242: 206, 243: 60, 244: 205, 245: 67, 246: 171,
        247: 208, 248: 55, 249: 167, 250: 172, 251: 60, 252: 207, 253: 164, 254: 67, 255: 206, 256: 167,
        257: 164, 258: 67, 259: 214, 260: 67,
        302: 181, 303: 178, 304: 201, 305: 91, 308: 164, 309: 188, 310: 166, 315: 209, 316: 210, 318: 85,
        320: 67, 321: 164, 322: 205, 323: 171, 324: 206, 325: 60, 326: 172, 327: 208, 328: 55, 329: 167,
        330: 67, 331: 164, 332: 214, 333: 167, 334: 60, 335: 205, 336: 208, 337: 207, 338: 205, 339: 206,
        340: 164, 341: 208, 342: 167, 343: 67, 344: 60, 345: 55, 346: 67,
        362: 162, 363: 90, 364: 93, 365: 164, 366: 164, 367: 167, 368: 206, 369: 67, 370: 207,
        391: 67, 392: 208, 393: 205, 394: 172, 395: 171, 396: 207, 397: 206, 398: 60, 399: 164, 400: 162,
        401: 167, 402: 205, 403: 67,
    }
    for k, v in explicit.items():
        tbl[k] = v
    return bytes(tbl)


def patch_vibhal(src_path: Path, out_dir: Path, verify_only: bool) -> None:
    buf = bytearray(src_path.read_bytes())
    md5_in = hashlib.md5(buf).hexdigest()
    if md5_in.startswith(EXPECTED_VIBHAL_FINAL_MD5):
        print(f"[SKIP] {src_path} already patched (MD5={md5_in}).")
        return
    segs = parse_load_segs(buf)
    rd = lambda va: struct.unpack_from("<I", buf, v2f(segs, va))[0]

    assert rd(0x162D0) == 0xD503233F, f"unexpected 0x162d0: {hex(rd(0x162D0))}"
    assert rd(0x1641C) == 0x52A8D809, f"unexpected 0x1641c: {hex(rd(0x1641C))}"
    assert rd(0x16430) == 0x529F0009, f"unexpected 0x16430: {hex(rd(0x16430))}"
    assert rd(0x1643C) == 0x72A8BFE9, f"unexpected 0x1643c: {hex(rd(0x1643C))}"
    assert rd(0x1DECC) == 0xF00000E9, f"unexpected 0x1decc: {hex(rd(0x1DECC))}"
    assert rd(0x10854) == 0x94008DE7, f"unexpected 0x10854: {hex(rd(0x10854))}"

    patch_u32(buf, segs, 0x10854, 0x2A1F03E0)
    patch_u32(buf, segs, 0x170F4, 0x2A1F03E0)
    patch_u32(buf, segs, 0x162D0, 0x2A1F03E0)
    patch_u32(buf, segs, 0x162D4, 0xD65F03C0)
    patch_u32(buf, segs, 0x1641C, 0x52A8DD09)
    patch_u32(buf, segs, 0x16430, 0x529E0009)
    patch_u32(buf, segs, 0x1643C, 0x72A8A7E9)
    patch_u32(buf, segs, 0x1DECC, enc_b(0x1DECC, 0x1DF5C))
    patch_u32(buf, segs, 0x1DF5C, 0x528999A9)
    patch_u32(buf, segs, 0x1DF60, 0x72A7A989)
    patch_u32(buf, segs, 0x1DF64, 0x1E270121)
    patch_u32(buf, segs, 0x1DF68, 0x1E216908)
    patch_u32(buf, segs, 0x1DF6C, enc_adrp(0x1DF6C, 0x3C000, 9))
    patch_u32(buf, segs, 0x1DF70, 0xBD001D28)
    patch_u32(buf, segs, 0x1DF74, enc_b(0x1DF74, 0x1DF84))

    out_md5 = hashlib.md5(buf).hexdigest()
    assert out_md5.startswith(EXPECTED_VIBHAL_FINAL_MD5), f"Unexpected vibhal MD5: {out_md5}"
    if verify_only:
        print(f"[OK  ] Verified {src_path} -> MD5={out_md5}")
        return
    out_dir.mkdir(parents=True, exist_ok=True)
    dst = out_dir / "vendor.xiaomi.hardware.vibratorfeature.service"
    dst.write_bytes(buf)
    os.chmod(dst, 0o755)
    print(f"[OK  ] Wrote {dst} (MD5={out_md5})")


def patch_oplus_bridge(src_path: Path, out_dir: Path, verify_only: bool) -> None:
    buf = bytearray(src_path.read_bytes())
    md5_in = hashlib.md5(buf).hexdigest()
    if md5_in.startswith(EXPECTED_OPLUS_FINAL_MD5):
        print(f"[SKIP] {src_path} already patched (MD5={md5_in}).")
        return
    segs = parse_load_segs(buf)
    rd = lambda va: struct.unpack_from("<I", buf, v2f(segs, va))[0]

    assert rd(0x1A18C) == 0xFC1B0FE8, f"unexpected perform_with_amplitude: {hex(rd(0x1A18C))}"
    assert rd(0x19D4C) == 0x51034C09, f"unexpected Catalog::xiaomi_effect: {hex(rd(0x19D4C))}"

    for va, word in [
        (0x1A1A4, 0x1E204008), (0x1A1A8, 0xAA0003F3), (0x1A1AC, 0x2A0103F8), (0x1A1B0, 0x2A0203F4),
        (0x1A1B4, 0x360000A4), (0x1A1B8, 0x1E204100), (0x1A1BC, 0xF9400E60),
        (0x1A1C0, enc_bl(0x1A1C0, 0x1A604)), (0x1A1C4, 0xD503201F), (0x1A1C8, 0xAA1303E0),
        (0x1A1CC, 0x2A1803E1), (0x1A1D0, 0x2A1403E2), (0x1A1D4, enc_bl(0x1A1D4, 0x1A408)),
        (0x1A1D8, 0x2A0003F6), (0x1A1DC, 0x2A0103F7), (0x1A1E0, enc_b(0x1A1E0, 0x1A290)),
    ]:
        patch_u32(buf, segs, va, word)

    tbl = build_waveform_table()
    tbl_off = v2f(segs, 0x50D0)
    buf[tbl_off : tbl_off + len(tbl)] = tbl

    # 2b. Final v7.3.1 haptic amplitude scale calibration at 0x52a4 (0.78f -> 0.92f)
    scale_off = v2f(segs, 0x52A4)
    assert struct.unpack_from("<I", buf, scale_off)[0] == 0x3F47AE14, "unexpected scale float at 0x52a4"
    struct.pack_into("<I", buf, scale_off, 0x3F6B851F)

    for va, word in [
        (0x19D4C, 0x7100E01F), (0x19D50, 0x54000061), (0x19D54, 0x52803340), (0x19D58, 0xD65F03C0),
        (0x19D5C, 0x7106501F), (0x19D60, 0x540000A2), (0x19D64, enc_adrp(0x19D64, 0x5000, 8)),
        (0x19D68, 0x91034108), (0x19D6C, 0x38604900), (0x19D70, 0xD65F03C0),
        (0x19D74, 0x7106781F), (0x19D78, 0x54000061), (0x19D7C, 0x52800040), (0x19D80, 0xD65F03C0),
        (0x19D84, 0x51067008), (0x19D88, 0x71007D1F), (0x19D8C, 0x54000068), (0x19D90, 0x52801180),
        (0x19D94, 0xD65F03C0), (0x19D98, 0x528015E0), (0x19D9C, 0xD65F03C0),
    ]:
        patch_u32(buf, segs, va, word)

    out_md5 = hashlib.md5(buf).hexdigest()
    assert out_md5.startswith(EXPECTED_OPLUS_FINAL_MD5), f"Unexpected oplus bridge MD5: {out_md5}"
    if verify_only:
        print(f"[OK  ] Verified {src_path} -> MD5={out_md5}")
        return
    out_dir.mkdir(parents=True, exist_ok=True)
    dst = out_dir / "vendor.oplus.hardware.vibrator-service"
    dst.write_bytes(buf)
    os.chmod(dst, 0o755)
    print(f"[OK  ] Wrote {dst} (MD5={out_md5})")


def main() -> int:
    ap = argparse.ArgumentParser(description="Patch Xiaomi & Oplus vibrator HAL services for adaptive multi-texture haptics")
    ap.add_argument("--vibhal", type=Path, help="Input odm/bin/hw/vendor.xiaomi.hardware.vibratorfeature.service")
    ap.add_argument("--oplus-vib", type=Path, help="Input odm/bin/hw/vendor.oplus.hardware.vibrator-service")
    ap.add_argument("--out-dir", type=Path, default=Path("./out"), help="Output directory")
    ap.add_argument("--verify-only", action="store_true", help="Verify offsets without writing output")
    args = ap.parse_args()

    if not args.vibhal and not args.oplus_vib:
        sys.exit("ERROR: Provide --vibhal and/or --oplus-vib.")
    if args.vibhal:
        patch_vibhal(args.vibhal, args.out_dir, args.verify_only)
    if args.oplus_vib:
        patch_oplus_bridge(args.oplus_vib, args.out_dir, args.verify_only)
    return 0


if __name__ == "__main__":
    sys.exit(main())
