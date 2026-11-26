> **Self-Contained Assets Note:** All 26 `odm/etc/camera/config/*` configs, `product/framework/com.oplus.camera.unit.sdk*.jar`, `product/etc/permissions/*`, and 78 `product/lib64/*.so` libraries are bundled directly in this folder. Fetch the `173.78 MB` patched `OplusCamera.apk` automatically via `bash scripts/fetch_release_assets.sh` (hosted on GitHub Releases `v7.3.1-assets`). Upstream repo: [`ampereforest/dada_coloros_cam_port`](https://github.com/ampereforest/dada_coloros_cam_port).

# Xiaomi 15 (`dada`) — ColorOS 17 `OplusCamera` Port (`NOT_COMPLETED` / WIP)

> **Status: `NOT_COMPLETED` (Experimental / Work-In-Progress)**
>
> This repository contains the source code (`DadaJpegSaver`, `DadaZoomAnimator`), unified smali patches (`com.oplus.camera.unit.sdk.jar` and `OplusCamera.apk`), and `/odm/etc/camera/config/camera_unit_config` patch used to bring up the ColorOS 17 `OplusCamera` (`v7.013.40`) on the **Xiaomi 15 (`dada`, SM8750)** running the ColorOS 17 V6 CN port (`PLZ110_17.0.0.107(CN01)`).
>
> Because Xiaomi's CamX/CHI + MIVI HAL architecture differs fundamentally from OPPO's proprietary `com.oplus.ocs.camera` / APS post-processing pipeline, **this port is `NOT_COMPLETED`**. Core viewfinder, multi-lens SAT zoom, 12.5MP YUV-to-JPEG still capture, and 8/8 video recording modes work, while full OPPO APS multi-frame computational photography, native portrait bokeh, and 50MP/RAW pipelines remain incomplete.
>
> **Strict No-Binaries Policy:** Zero proprietary `.apk`, `.jar`, `.so`, or firmware blobs are included in this repository. You must extract the base files from your own official donor firmware images.

---

## 1. Required Donor Firmware & Base Artifacts

| Artifact | Donor Firmware | Partition Path | Base Size | Base MD5 |
|---|---|---|---|---|
| `OplusCamera.apk` (`v7.013.40`) | OPPO Find X8 (`PMX110_17.0.0.116(CN01)`) | `/my_product/app/OplusCamera/OplusCamera.apk` | `169,769,897 B` | `258b77bf8622014c6352081063195461` |
| `com.oplus.camera.unit.sdk.jar` | OnePlus 13 / ColorOS 17 port (`PLZ110_17.0.0.107(CN01)`) | `/my_product/product_overlay/framework/com.oplus.camera.unit.sdk.jar` | `5,357,287 B` | `9ef857845873a90e208771710b619925` |
| `camera_unit_config` | OPPO Find X8 (`PMX110_17.0.0.116(CN01)`) | `/odm/etc/camera/config/camera_unit_config` | `26,153 B` | `1bef30ce12d1d7591d46bb6ca3c46ee0` |

Additional stock companion files required on device (unmodified from `PMX110` / `PLZ110`):
- `/product/framework/com.oplus.camera.unit.sdk.adapter.jar`
- `/product/etc/permissions/com.oplus.camera.unit.sdk_product.xml`
- `/product/etc/permissions/oplus_camera_default_grant_permissions_list.xml`
- `/my_product/lib64/libAPSClient*.so` + `libCombineLutJni.so` (and companion APS JNI libraries extracted to `/product/lib64/` or APK `lib/arm64-v8a/`)

---

## 2. Current Feature Matrix (`NOT_COMPLETED` / WIP)

### What Currently Works
- **Live Camera2 Viewfinder Across Modes:**
  - `PHOTO`, `VIDEO`, `PRO` (Manual), `PORTRAIT`, `MORE`, and **Front Camera** (`Camera ID 1`) all open and stream live preview without session aborts (`opMode = 0` / `0x801D` mapping on Xiaomi CamX).
- **3-Lens Rear Optical Array (`0.6x / 1x / 2x / 2.6x`) via Logical SAT Camera `0`:**
  - Maps OPPO's zoom pipeline directly onto Xiaomi 15's logical multi-camera `0` (`physicalIds = [3 (UW 14mm), 2 (Wide 23mm), 4 (Tele 60mm)]`) via `CaptureRequest.CONTROL_ZOOM_RATIO` (`0.6f..10.0f`).
  - Exposes `[0.6x, 1x, 2x, 2.6x]` zoom chips (`ULTRA_WIDE / WIDE / DUAL / TELE`) in the UI with `1.0x` startup default.
- **90Hz Drift-Free Smooth SAT Zoom Animator (`DadaZoomAnimator`):**
  - Interpolates discrete zoom chip taps (`0.6x ↔ 1x ↔ 2x ↔ 2.6x`) and fine-tune steps on `CameraUnitControl`'s handler thread using `postAtTime` (`FRAME_MS = 11ms`, blended cosine S-curve + quad ease-out) with a `2.077x` step-1 Tele pre-warm kick so Xiaomi CamX (`chimcx3partpolicy.cpp`) completes `W+T → T+W` optical handoff smoothly mid-glide.
  - Bypasses `OplusCamera`'s Video-mode physical `rear_tele` teardown (`m2.smali`), keeping all non-8K video modes on logical SAT Camera `0` at full 60 FPS with zero blur-overlay transitions.
- **Still Capture (`DadaJpegSaver`, 12.5MP `4096×3072` Rear / `3264×2448` Front, q100 JPEG + Full EXIF):**
  - Intercepts the `FORMAT_YUV_420_888` (`format: 35`) still capture buffer routed through Xiaomi's `Thirdparty` SAT MIVI pipeline (`Util.convertNV21DataToJpeg` at quality `100`), writes complete Xiaomi 15 EXIF metadata (`Make=Xiaomi`, `Model=Xiaomi 15`, per-lens `FocalLength` / `FocalLengthIn35mmFilm`: `2.16mm/14mm`, `6.55mm/23mm`, `9.00mm/60mm`, front `2.83mm/21mm`), commits directly to `MediaStore` (`DCIM/Camera`), and purges orphan pending `IMG2%` placeholder rows.
- **Full 8/8 Video Resolution & Frame-Rate Matrix (with Audio):**
  - `720p @ 30fps`, `720p @ 60fps`
  - `1080p @ 30fps`, `1080p @ 60fps`
  - `4K @ 24fps`, `4K @ 30fps`, `4K @ 60fps`
  - **`8K @ 30fps` (`7680×4320` HEVC):** Automatically swaps from logical SAT Camera `0` to physical 50MP main sensor Camera `2` with Xiaomi `operationMode = 0x801D` (`32797`, `m_currentSensorModeIndex: 26`), and seamlessly swaps back to Camera `0` when exiting 8K.
- **Developer Options Toggle Support:**
  - Can be enabled/disabled on demand (`pm enable` / `pm disable-user --user 0 com.oplus.camera`) alongside `MiuiCamera` (`com.android.camera`) with zero HAL conflict when closed.

### Known Limitations (Why Status is `NOT_COMPLETED`)
1. **No Native OPPO APS Multi-Frame / Hasselblad RAW Pipeline:** Still capture relies on Xiaomi's single-stream `Thirdparty` MIVI `YUV_420_888` output converted via `Util.convertNV21DataToJpeg` + `DadaJpegSaver` rather than OPPO's proprietary `libAPSClient` multi-frame HDR/Night fusion.
2. **Portrait Mode (`PORTRAIT`) Depth / Bokeh Incomplete:** Portrait mode streams preview and switches modes cleanly, but uses single-stream `capture_yuv` without dual-camera depth-map bokeh synthesis.
3. **50MP Hi-Res / Pro RAW / Master Mode Incomplete:** High-resolution 50MP full-bayer still capture and DNG RAW capture are not wired to Xiaomi's physical sensor remosaic opmodes.
4. **In-App Thumbnail Session Link:** Because `DadaJpegSaver` purges the app's unfulfilled APS `IMG2%` placeholder row and inserts a clean `IMG_<timestamp>.jpg` MediaStore entry, tapping the in-app bottom-left thumbnail immediately after shooting may reference the purged placeholder URI until Gallery is opened directly.
5. **Front Camera EXIF Mirroring:** Front camera stills currently use standard `Orientation = 6` without horizontal flip post-processing.

---

## 3. Repository Layout

```text
dada_coloros_cam_port/
├── README.md
├── patches/
│   ├── camera_unit_config.patch          # /odm/etc/camera/config/camera_unit_config diff (orig -> p5)
│   ├── com.oplus.camera.unit.sdk.patch   # SDK classes.dex smali diff (orig -> sdk_p33)
│   ├── opluscamera-classes.patch         # OplusCamera.apk classes.dex smali diff
│   ├── opluscamera-classes3.patch        # OplusCamera.apk classes3.dex smali diff
│   ├── opluscamera-classes5.patch        # OplusCamera.apk classes5.dex smali diff
│   └── opluscamera-classes7.patch        # OplusCamera.apk classes7.dex smali diff
└── src/
    ├── apk/com/oplus/camera/util/
    │   ├── DadaJpegSaver.java            # YUV->JPEG MediaStore committer, Xiaomi 15 EXIF writer & pending-row cleaner
    │   ├── DadaJpegSaver.smali
    │   └── DadaJpegSaver$1.smali
    └── sdk/com/oplus/ocs/camera/producer/device/
        ├── DadaZoomAnimator.java         # 90Hz drift-free CONTROL_ZOOM_RATIO SAT animator
        ├── DadaZoomAnimator.smali
        └── DadaZoomAnimator$1.smali
```

---

## 4. Architecture & Patch Summary

### A. `patches/com.oplus.camera.unit.sdk.patch` (`com.oplus.camera.unit.sdk.jar`)
- **`Camera2Impl.smali`:**
  - Strips unsupported `com.oplus.*` vendor tags on Xiaomi CamX so session configuration and repeating preview requests succeed.
  - Forces `CaptureRequest.CONTROL_ZOOM_RATIO` (`0.6f..10.0f` on rear logical SAT Camera `0`, `1.0f..10.0f` on front/physical cameras) in `setZoomRatio`, storing `Util.sDadaLastZoomRatio`.
  - Hooks `DadaZoomAnimator` into `startPreview`, `takePicture`, `createNewSession`, `stopPreview`, `closeOldSession`, and `closeCameraDevice` for 90Hz SAT zoom transitions on Camera `0`.
  - Swaps `Camera 0 ↔ Camera 2` in `createNewSession` when entering/leaving `operationMode = 0x801D` (`32797`) for native `7680×4320` 8K30 recording.
  - Captures `FORMAT_YUV_420_888` (`format: 35`) still buffers in the `ImageReader` callback, encodes q100 JPEG via `Util.convertNV21DataToJpeg`, and invokes `com.oplus.camera.util.DadaJpegSaver.saveJpeg(byte[], int, int, int)` via reflection.
- **`ZoomHelper.smali`:**
  - Reads `CameraCharacteristics.CONTROL_ZOOM_RATIO_RANGE` (`0.6f..10.0f`) when `com.oplus.ultra.wide.zoom.range` is absent so `getMinZoomValue()` returns `0.6f` on rear logical SAT Camera `0`.
- **`Util.smali`:**
  - Raises `convertNV21DataToJpeg` quality from `98` to `100`, clamps `getCropRegionForZoom` divisor `>= 1.0f`, and holds `sDadaLastZoomRatio` / `sDadaCameraId`.
- **`DadaZoomAnimator.java` / `.smali`:**
  - 90Hz (`FRAME_MS = 11L`, `Handler.postAtTime`) drift-free zoom interpolator with blended cosine S-curve (55%) + quadratic ease-out (45%) and step-1 `2.077x` Tele pre-warm kick.

### B. `patches/opluscamera-classes*.patch` (`OplusCamera.apk`)
- **`classes.dex` (`CameraConfig.smali`, `CameraSettingsConfig.smali`, etc.):**
  - Unlocks full 8/8 video resolution & FPS options (`720p30/60`, `1080p30/60`, `4K24/30/60`, `8K30`) and silences non-existent OPPO account/cloud crash paths.
- **`classes3.dex` (`od/b.smali`):**
  - Prevents null/missing OPPO vendor tag table crash during startup capability initialization.
- **`classes5.dex` (`com/oplus/camera/feature/focus/ui/a.smali` — `FocusIndicatorRotateLayout`):**
  - Adds `dadaCenterIfUnplaced()` and `onLayout` centering guard so the focus indicator ring centers accurately on startup and tracks user tap-to-focus coordinates `(x, y)` 1:1.
- **`classes7.dex`:**
  - `com/oplus/camera/feature/zoom/ui/m2.smali`: Exposes `[0.6f, 1.0f, 2.0f, 2.6f]` (`ULTRA_WIDE / WIDE / DUAL / TELE`) zoom chips on rear camera (`zoomBarType: 111100`) and bypasses `:goto_8c` / `m2.S(FI)Z` physical `rear_tele` teardown in Video mode.
  - `il/f.smali`: Bypasses `1.0f` lower zoom clamp on rear camera so `0.6x` reaches `CONTROL_ZOOM_RATIO`.
  - `com/oplus/camera/module/BaseMode.smali`: Keeps `Bb(SwitchEventType)` & post-capture mode/camera switch state unblocked (`F0` re-armed) and prevents `720p60` from clamping back to `30fps`.
  - `com/oplus/camera/module/processor/captureprocessor/CaptureProcessor.smali`: Re-arms shutter/switch/zoom UI (`kp/g0$l`, `g1.l(0)`, `k4.m().Uh(true)`, `ZoomUIContainer.l0(true)`) 300ms after YUV capture completion.
  - `com/oplus/camera/util/DadaJpegSaver.smali` (+ `$1.smali`): Saves full-res JPEG + Xiaomi 15 EXIF and purges orphan pending rows.

### C. `patches/camera_unit_config.patch` (`/odm/etc/camera/config/camera_unit_config`)
- Maps OPPO custom operation modes (`common`, `video`, `fast_video`, `professional`, `portrait`, `night`, `uhd`, `60fps`, `hdr`, etc.) to `"0"` (`NORMAL_MODE` for Xiaomi CamX `Thirdparty` SAT pipeline), and `"8k"` to `"801D"` (`0x801D` on physical main Camera `2`).
- Maps logical camera roles (`rear_main`, `rear_sat` → `"0"`, `front_main` → `"1"`, `rear_wide` → `"3"`, `rear_tele` → `"4"`) and configures `preview + capture_yuv` streams across photo, pro, and portrait modes.

---

## 5. Step-by-Step Build & Deployment Guide

### Prerequisites
- `baksmali` & `smali` (`v2.5.2`)
- `zipalign` & `apksigner` (Android Build Tools)
- Standard `patch`, `unzip`, `zip`, `python3`

### Step 1 — Patch & Rebuild `com.oplus.camera.unit.sdk.jar`
```bash
mkdir -p build/sdk
unzip -q com.oplus.camera.unit.sdk.jar classes.dex -d build/sdk
baksmali d build/sdk/classes.dex -o build/sdk/smali

patch -p1 -d build/sdk/smali < patches/com.oplus.camera.unit.sdk.patch

smali a build/sdk/smali -o build/sdk/classes.dex
cp com.oplus.camera.unit.sdk.jar build/com.oplus.camera.unit.sdk.patched.jar
(cd build/sdk && zip -q -u ../com.oplus.camera.unit.sdk.patched.jar classes.dex)
```

### Step 2 — Patch & Rebuild `OplusCamera.apk`
```bash
mkdir -p build/apk
cp OplusCamera.apk build/OplusCamera.patched.apk

for dex in classes classes3 classes5 classes7; do
    unzip -q OplusCamera.apk "${dex}.dex" -d build/apk
    baksmali d "build/apk/${dex}.dex" -o "build/apk/${dex}_smali"
    patch -p1 -d "build/apk/${dex}_smali" < "patches/opluscamera-${dex}.patch"
    smali a "build/apk/${dex}_smali" -o "build/apk/${dex}.dex"
    (cd build/apk && zip -q -0 ../OplusCamera.patched.apk "${dex}.dex")
done

# Align to 16KB page boundary and sign (v1+v2+v3, v4 disabled)
zipalign -P 16 -f 4 build/OplusCamera.patched.apk build/OplusCamera.aligned.apk
apksigner sign \
    --ks your-release-key.p12 \
    --ks-type PKCS12 \
    --ks-pass pass:YOUR_PASSWORD \
    --v1-signing-enabled true \
    --v2-signing-enabled true \
    --v3-signing-enabled true \
    --v4-signing-enabled false \
    --out build/OplusCamera.signed.apk \
    build/OplusCamera.aligned.apk
rm -f build/OplusCamera.signed.apk.idsig
```

### Step 3 — Patch `camera_unit_config`
```bash
cp camera_unit_config build/camera_unit_config.patched
patch -p1 build/camera_unit_config.patched < patches/camera_unit_config.patch
```

### Step 4 — Stage in KernelSU + NoMount Module (`/data/adb/modules/cos17_opluscam_test/`)
Stage the built artifacts with `0:0` ownership, `0644` permissions (`0755` for directories), and SELinux contexts (`u:object_r:system_file:s0` for system/product/my_product files, `u:object_r:vendor_configs_file:s0` for `/odm/etc/camera/config/camera_unit_config`), clear `/data/system/package_cache/*`, and reboot:
- `/data/adb/modules/cos17_opluscam_test/product/framework/com.oplus.camera.unit.sdk.jar`
- `/data/adb/modules/cos17_opluscam_test/my_product/product_overlay/framework/com.oplus.camera.unit.sdk.jar`
- `/data/adb/modules/cos17_opluscam_test/my_product/app/OplusCamera/OplusCamera.apk`
- `/data/adb/modules/cos17_opluscam_test/odm/etc/camera/config/camera_unit_config`
