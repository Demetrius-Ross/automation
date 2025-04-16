@echo off
setlocal enabledelayedexpansion

:: === PRESTEP ===
echo ================= PRE-UPDATE CHECK =================
echo Make sure the following are TRUE before continuing:
echo.
echo 1. The cockpit is TURNED ON.
echo 2. SimIO is in MAINTENANCE MODE.
echo 3. EPIC is properly CONFIGURED.
echo.
pause

:: === MENU ===
:menu
cls
echo ================= SIMULATOR UPDATE =================
echo.
echo 1. Prepare Simulator for Update (registry swap)
echo 2. Finalize Update (revert registry for simulation use)
echo 3. Exit
echo.
set /p choice="Select an option: "

if "%choice%"=="1" goto prepare
if "%choice%"=="2" goto finalize
if "%choice%"=="3" goto end
echo Invalid choice. Try again.
goto menu

:: === STEP 1: PREPARE SIMULATOR FOR UPDATE ===
:prepare
echo.
echo ===== Starting Update Preparation =====

:: === Define target-specific paths ===
set "agm1_path=C:\Load CD\PC12_10_11\module\agm1\appbin\escape.le_reg"
set "agm2_path=C:\Load CD\PC12_10_11\module\agm2\appbin\escape.le_reg"

for %%T in (agm1 agm2) do (
    echo.
    echo === Processing %%T ===

    REM Choose correct file path for this target
    if "%%T"=="agm1" set "filepath=!agm1_path!"
    if "%%T"=="agm2" set "filepath=!agm2_path!"

    REM Step 1: Ping check
    ping -n 1 %%T >nul
    if errorlevel 1 (
        echo ERROR: %%T is not reachable. Skipping.
        goto nextTarget
    ) else (
        echo SUCCESS: %%T is reachable.
    )

    REM Step 2: Run ls and check for file variants
    echo ls > ls_%%T.ftp
    echo bye >> ls_%%T.ftp
    ftpshell %%T < ls_%%T.ftp > ls_output_%%T.txt

    set "found=0"
    findstr /C:"Escape.le_reg" ls_output_%%T.txt >nul && set "found=1"
    findstr /C:"escape.le_reg" ls_output_%%T.txt >nul && set "found=1"

    if !found! == 0 (
        echo.
        echo CRITICAL: Neither Escape.le_reg nor escape.le_reg found on %%T!
        echo Please verify the registry before proceeding.
        goto abort
    ) else (
        echo File exists on %%T — proceeding with upload.
    )

    REM Step 3: Upload the new file — NO BYE
    echo put !filepath! > upload_%%T.ftp
    ftpshell %%T < upload_%%T.ftp > upload_log_%%T.txt

    REM === SAFETY DELAY ===
    echo.
    echo Waiting 60 seconds to ensure transfer completes fully...
    timeout /t 60 >nul

    REM Step 4: Close session with BYE to flush log
    echo bye > close_%%T.ftp
    ftpshell %%T < close_%%T.ftp >> upload_log_%%T.txt

    echo Checking transfer result...
    findstr /C:"Transfer complete.  Closing data connection." upload_log_%%T.txt >nul
    if !errorlevel! == 0 (
        echo SUCCESS: File uploaded to %%T.
    ) else (
        echo ERROR: Upload failed or incomplete for %%T! Do not proceed further.
        goto nextTarget
    )

    REM Step 5: Final verification
    echo ls > verify_%%T.ftp
    echo bye >> verify_%%T.ftp
    ftpshell %%T < verify_%%T.ftp > verify_output_%%T.txt

    findstr /C:"escape.le_reg" verify_output_%%T.txt >nul
    if !errorlevel! == 0 (
        echo CONFIRMED: escape.le_reg is present on %%T.
    ) else (
        echo ERROR: escape.le_reg not found after upload.
    )

    :nextTarget
)

goto end

:: === STEP 2: FINALIZE UPDATE (Placeholder) ===
:finalize
echo.
echo ===== Finalize Update =====
echo This step is not yet implemented.
pause
goto menu

:abort
echo.
echo ===== ABORTING PROCESS =====
pause
goto end

:end
echo.
echo All operations complete.
pause
exit /b
