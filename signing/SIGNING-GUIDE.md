# Custom Platform & App Signing Guide (`signing/`)

ColorOS 17 V6 stock system APKs (`framework-res.apk`, `TeleService.apk`, `Settings.apk`, `SystemUI.apk`, `Wallpapers.apk`, etc.) are signed with OPPO/Oplus's private RSA-4096 certificate (`SHA-256: e49802409584ce53152a9000820a51e4fa8a723b7bcc263e335240acf100bf9e`). Because no public Oplus private key exists, **every modified system APK must be re-signed with your own locally generated certificates**, and `services.jar` must recognize your certificate alongside Oplus's platform certificate.

> **Security Rule:** Never commit anything inside `signing/keys/`. This directory is ignored by `.gitignore` (`*.pk8`, `*.p12`, `*.jks`, `*.pem`, `*.key`, `*.pass`). Back up your generated `signing/keys/` securely offline so future updates keep the same app signatures.

---

## 1. How Custom Platform Signing Works on Rootless ColorOS 17

1. **Generate your own keys (`signing/generate_keys.sh`):**
   - `platform` — Signs modified platform/shared-UID system APKs (`SystemUI.apk`, `Settings.apk`, `TeleService.apk`, `Wallpapers.apk`, `MiuiCamera.apk`, `OplusCamera.apk`, `aon.frameworkres.overlay.product.apk`, `DadaAngleUI.apk`).
   - `media` — Standard AOSP media key (optional if modifying media-shared-UID APKs).
   - `shared` — Standard AOSP shared key (optional if modifying `android.uid.shared` APKs).
   - `releasekey` — Standard AOSP release/testkey fallback for standalone custom apps.
   - `esim-release` — Dedicated key signing **both** `OpenEUICC.apk` and `DadaEsimUI.apk` so `IDadaEsimBridge` (`SIGNATURE_MATCH`) and `CallerPolicy.java` accept eSIM bridge calls. *(You may also reuse `platform` for both if preferred, or keep `esim-release` separate — `render_framework_signer.py` handles both automatically.)*
2. **Stamp your certificate SHA-256 into framework patches (`signing/render_framework_signer.py`):**
   - Reads `signing/keys/platform.x509.pem` and writes its 32 signed bytes into `modules/02-esim-compat/patches/services-platform-signer-compat.patch` (`PackageManagerServiceUtils.isDadaPlatformCompat()` & `isDadaSigner()`).
   - Reads `signing/keys/esim-release.x509.pem` (or `platform.x509.pem` if unified) and updates `CERT_SHA256` in `modules/02-esim-compat/integration/owner/org/sourceowned/n3/runtime/v2/CallerPolicy.java`.
   - With `PackageManagerServiceUtils.isDadaPlatformCompat()` + `SELinuxMMAC` patched in `services.jar`, Android accepts your re-signed `TeleService.apk`, `Settings.apk`, and `SystemUI.apk` in `sharedUserId="android.uid.phone"` / `"android.uid.system"` and assigns them the `platform` SELinux domain cleanly on factory reset!
3. **Preserve SystemUI Runtime Permissions on Clean Flash:**
   - Because re-signed `SystemUI.apk` no longer matches `framework-res.apk`'s raw certificate directly during AOSP's `DefaultPermissionGrantPolicy`, **make sure Module 08's two default-permission XMLs are installed**:
     - `/system/etc/default-permissions/default-permissions-cos17-dada.xml`
     - `/my_product/etc/permissions/cos17_dada_default_grant_permissions_list.xml`
   - Without these two XMLs, toggling Bluetooth on a clean flash causes `SystemUI` to crash-loop on `BLUETOOTH_CONNECT` (`reboot,ui_repair_abandoned`).
4. **Re-sign modified APKs (`signing/sign_rom_apks.sh`):**
   - Automatically reads keys from `signing/keys/`, runs `zipalign -P 16 -f 4` (16 KiB page alignment for Android 15+/17), and signs with `apksigner` (`v1 + v2 + v3`, `v4=false`).

---

## 2. Which APKs MUST vs. MUST NOT Be Re-Signed

| Category | APKs | Signing Action |
| :--- | :--- | :--- |
| **Modified Platform / System APKs** | `SystemUI.apk`, `Settings.apk`, `TeleService.apk`, `Wallpapers.apk`, `MiuiCamera.apk`, `OplusCamera.apk`, `aon.frameworkres.overlay.product.apk`, `DadaAngleUI.apk` | **Re-sign with `signing/keys/platform.p12`** (automatically handled by `signing/sign_rom_apks.sh`) |
| **eSIM Bridge Pair** | `OpenEUICC.apk`, `DadaEsimUI.apk` | **Re-sign BOTH with `signing/keys/esim-release.p12`** (must match `CallerPolicy.java` `CERT_SHA256`) |
| **Titanium Browser (`io.github.jqssun.helium`)** | `product/app/TitaniumBrowser/TitaniumBrowser.apk` | **DO NOT RE-SIGN!** Fetch the pre-signed official APK from [`ampereforest/android-titanium-browser/releases/latest`](https://github.com/ampereforest/android-titanium-browser/releases/latest) via `modules/09-apps-and-ui/titanium-browser/fetch_titanium_browser.sh` so standalone updates install cleanly without reflashing the ROM. |
| **Untouched OEM / Google / Third-Party APKs** | `OplusLauncher.apk`, `OcrScanner.apk`, `BaseOcrScanner.apk`, `OseeTileLauncher.apk`, `Gemini.apk`, `LatinImeGoogle.apk`, `VelvetCtS.apk`, `OpenAlive.apk` | **DO NOT RE-SIGN!** Keep original signatures intact so Play Store / ColorOS / upstream updates continue working cleanly. |

---

## 3. Quick-Start Commands

```bash
# Step 1: Generate your own RSA-4096 keys in signing/keys/
bash signing/generate_keys.sh

# Step 2: Automatically stamp your generated certificates' SHA-256 digests into
#         services-platform-signer-compat.patch & eSIM CallerPolicy.java
python3 signing/render_framework_signer.py

# Step 3: After patching APKs inside your unpacked ROM tree, align & sign all modified APKs
#         (explicitly skips TitaniumBrowser.apk and untouched stock-signed APKs)
bash signing/sign_rom_apks.sh --rom-root /path/to/unpacked_rom
```

### Prerequisites
- `openssl` (3.x recommended)
- `keytool` (JDK 17+)
- `zipalign` and `apksigner` (Android SDK Build-Tools 35+ / 37.0.0; set `ANDROID_BUILD_TOOLS=/path/to/build-tools/37.0.0` if not in `PATH`)
