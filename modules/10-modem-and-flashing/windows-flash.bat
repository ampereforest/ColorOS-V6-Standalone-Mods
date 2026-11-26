@echo off
setlocal EnableExtensions
rem windows-flash.bat - converted 1:1 from linux-flash.sh (same partitions, order, erase/wipe and slot commands).
rem Uses the bundled Google platform-tools fastboot.exe and zstd.exe from the binary\ folder next to this script. Extra arguments (e.g. -s SERIAL) are passed to every fastboot call, like "$@".
cd /d "%~dp0"
set "BIN_DIR=%~dp0binary"
set "FASTBOOT=%BIN_DIR%\fastboot.exe"
set "ZSTD=%BIN_DIR%\zstd.exe"
set "FB_ARGS=%*"

if not exist "%FASTBOOT%" (
    echo ERROR: fastboot.exe not found in binary folder: "%FASTBOOT%"
    goto :fail
)
if not exist "%BIN_DIR%\AdbWinApi.dll" (
    echo ERROR: AdbWinApi.dll not found in binary folder: "%BIN_DIR%"
    goto :fail
)
if not exist "%BIN_DIR%\AdbWinUsbApi.dll" (
    echo ERROR: AdbWinUsbApi.dll not found in binary folder: "%BIN_DIR%"
    goto :fail
)
if not exist "%BIN_DIR%\libwinpthread-1.dll" (
    echo ERROR: libwinpthread-1.dll not found in binary folder: "%BIN_DIR%"
    goto :fail
)

rem Prefer the bundled zstd.exe; fall back to zstd on PATH only if it is not bundled.
set "ZSTD_EXE=%ZSTD%"
if not exist "%ZSTD%" set "ZSTD_EXE=zstd"

echo Note: 'OKAY' indicates success. 'FAILED' usually indicates a faulty USB cable or port.

rem Decompress super.img if compressed with zstd
if exist "images\super.img.zst" (
    echo Decompressing super.img.zst...
    if not exist "%ZSTD%" (
        where zstd >nul 2>&1
        if errorlevel 1 (
            echo ERROR: images\super.img.zst found but binary\zstd.exe is missing and zstd is not on PATH. Decompress it to images\super.img first.
            goto :fail
        )
    )
    "%ZSTD_EXE%" --rm -d "images\super.img.zst" -o "images\super.img"
    if errorlevel 1 (
        echo ERROR: zstd decompression failed.
        goto :fail
    )
)
if not exist "images\super.img" (
    echo ERROR: images\super.img not found.
    goto :fail
)

rem Prompt for data wipe
set "wipeData="
set /p "wipeData=First-time flash? Enter Y to wipe all data, or N to upgrade and keep data (Y/N): "

echo.
echo Flashing low-level firmware partitions...

call :fb flash abl_ab "images\abl.img" || goto :fail
call :fb flash xbl_ab "images\xbl.img" || goto :fail
call :fb flash xbl_config_ab "images\xbl_config.img" || goto :fail
call :fb flash xbl_ramdump_ab "images\xbl_ramdump.img" || goto :fail
call :fb flash imagefv_ab "images\imagefv.img" || goto :fail
call :fb flash aop_ab "images\aop.img" || goto :fail
call :fb flash aop_config_ab "images\aop_config.img" || goto :fail
call :fb flash bluetooth_ab "images\bluetooth.img" || goto :fail
call :fb flash boot_ab "images\boot.img" || goto :fail
call :fb flash cpucp_ab "images\cpucp.img" || goto :fail
call :fb flash cpucp_dtb_ab "images\cpucp_dtb.img" || goto :fail
call :fb flash devcfg_ab "images\devcfg.img" || goto :fail
call :fb flash dsp_ab "images\dsp.img" || goto :fail
call :fb flash dtbo_ab "images\dtbo.img" || goto :fail
call :fb flash featenabler_ab "images\featenabler.img" || goto :fail
call :fb flash hyp_ab "images\hyp.img" || goto :fail
call :fb flash idmanager_ab "images\idmanager.img" || goto :fail
call :fb flash countrycode_ab "images\countrycode.img" || goto :fail
call :fb flash init_boot_ab "images\init_boot.img" || goto :fail
call :fb flash keymaster_ab "images\keymaster.img" || goto :fail
call :fb flash modem_ab "images\modem.img" || goto :fail
call :fb flash modemfirmware_ab "images\modemfirmware.img" || goto :fail
call :fb flash multiimgqti_ab "images\multiimgqti.img" || goto :fail
call :fb flash pdp_ab "images\pdp.img" || goto :fail
call :fb flash pdp_cdb_ab "images\pdp_cdb.img" || goto :fail
call :fb flash pvmfw_ab "images\pvmfw.img" || goto :fail
call :fb flash qupfw_ab "images\qupfw.img" || goto :fail
call :fb flash recovery_ab "images\recovery.img" || goto :fail
call :fb flash shrm_ab "images\shrm.img" || goto :fail
call :fb flash soccp_dcd_ab "images\soccp_dcd.img" || goto :fail
call :fb flash soccp_debug_ab "images\soccp_debug.img" || goto :fail
call :fb flash spuservice_ab "images\spuservice.img" || goto :fail
call :fb flash tz_ab "images\tz.img" || goto :fail
call :fb flash uefi_ab "images\uefi.img" || goto :fail
call :fb flash uefisecapp_ab "images\uefisecapp.img" || goto :fail
call :fb flash vbmeta_ab "images\vbmeta.img" || goto :fail
call :fb flash vbmeta_system_ab "images\vbmeta_system.img" || goto :fail
call :fb flash vendor_boot_ab "images\vendor_boot.img" || goto :fail
call :fb flash vm-bootsys_ab "images\vm-bootsys.img" || goto :fail

echo Flashing system partition (speed depends on PC performance)...
call :fb erase super || goto :fail
call :fb flash super "images\super.img" || goto :fail

rem Format data if user selected Y/y
if /i "%wipeData%"=="y" (
    echo Formatting userdata, metadata, and frp partitions...
    call :fb erase userdata || goto :fail
    call :fb erase metadata || goto :fail
    call :fb erase frp || goto :fail
    echo.
)

echo Setting active slot to A and rebooting...
call :fb set_active a || goto :fail
call :fb reboot || goto :fail

echo.
echo All partitions flashed successfully. If the device fails to boot, delete the extracted folder, re-extract the archive, and flash again.
pause
endlocal
exit /b 0

:fb
rem Run one fastboot command and stop on any non-zero exit code.
"%FASTBOOT%" %FB_ARGS% %*
set "FB_RC=%errorlevel%"
if not "%FB_RC%"=="0" (
    echo.
    echo FAILED ^(exit code %FB_RC%^): fastboot %FB_ARGS% %*
    exit /b %FB_RC%
)
exit /b 0

:fail
echo.
echo Flashing stopped because of the error above. Nothing after it was run.
pause
endlocal
exit /b 1
