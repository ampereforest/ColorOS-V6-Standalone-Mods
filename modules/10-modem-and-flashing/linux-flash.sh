#!/bin/bash

echo "Note: 'OKAY' indicates success. 'FAILED' usually indicates a faulty USB cable or port."

# Decompress super.img if compressed with zstd
if [ -f "images/super.img.zst" ]; then
    echo "Decompressing super.img.zst..."
    zstd --rm -d images/super.img.zst -o images/super.img
fi

# Prompt for data wipe
read -p "First-time flash? Enter Y to wipe all data, or N to upgrade and keep data (Y/N): " wipeData

echo ""
echo "Flashing low-level firmware partitions..."

fastboot "$@" flash abl_ab images/abl.img
fastboot "$@" flash xbl_ab images/xbl.img
fastboot "$@" flash xbl_config_ab images/xbl_config.img
fastboot "$@" flash xbl_ramdump_ab images/xbl_ramdump.img
fastboot "$@" flash imagefv_ab images/imagefv.img
fastboot "$@" flash aop_ab images/aop.img
fastboot "$@" flash aop_config_ab images/aop_config.img
fastboot "$@" flash bluetooth_ab images/bluetooth.img
fastboot "$@" flash boot_ab images/boot.img
fastboot "$@" flash cpucp_ab images/cpucp.img
fastboot "$@" flash cpucp_dtb_ab images/cpucp_dtb.img
fastboot "$@" flash devcfg_ab images/devcfg.img
fastboot "$@" flash dsp_ab images/dsp.img
fastboot "$@" flash dtbo_ab images/dtbo.img
fastboot "$@" flash featenabler_ab images/featenabler.img
fastboot "$@" flash hyp_ab images/hyp.img
fastboot "$@" flash idmanager_ab images/idmanager.img
fastboot "$@" flash countrycode_ab images/countrycode.img
fastboot "$@" flash init_boot_ab images/init_boot.img
fastboot "$@" flash keymaster_ab images/keymaster.img
fastboot "$@" flash modem_ab images/modem.img
fastboot "$@" flash modemfirmware_ab images/modemfirmware.img
fastboot "$@" flash multiimgqti_ab images/multiimgqti.img
fastboot "$@" flash pdp_ab images/pdp.img
fastboot "$@" flash pdp_cdb_ab images/pdp_cdb.img
fastboot "$@" flash pvmfw_ab images/pvmfw.img
fastboot "$@" flash qupfw_ab images/qupfw.img
fastboot "$@" flash recovery_ab images/recovery.img
fastboot "$@" flash shrm_ab images/shrm.img
fastboot "$@" flash soccp_dcd_ab images/soccp_dcd.img
fastboot "$@" flash soccp_debug_ab images/soccp_debug.img
fastboot "$@" flash spuservice_ab images/spuservice.img
fastboot "$@" flash tz_ab images/tz.img
fastboot "$@" flash uefi_ab images/uefi.img
fastboot "$@" flash uefisecapp_ab images/uefisecapp.img
fastboot "$@" flash vbmeta_ab images/vbmeta.img
fastboot "$@" flash vbmeta_system_ab images/vbmeta_system.img
fastboot "$@" flash vendor_boot_ab images/vendor_boot.img
fastboot "$@" flash vm-bootsys_ab images/vm-bootsys.img

echo "Flashing system partition (speed depends on PC performance)..."
fastboot "$@" erase super
fastboot "$@" flash super images/super.img

# Format data if user selected Y/y
if [[ "${wipeData,,}" == "y" ]]; then
    echo "Formatting userdata, metadata, and frp partitions..."
    fastboot "$@" erase userdata
    fastboot "$@" erase metadata
    fastboot "$@" erase frp
    echo ""
fi

echo "Setting active slot to A and rebooting..."
fastboot "$@" set_active a
fastboot "$@" reboot

echo ""
echo "All partitions flashed successfully. If the device fails to boot, delete the extracted folder, re-extract the archive, and flash again."
