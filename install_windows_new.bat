@echo off

REM =======================================================
REM  Scammer Hunter - PhonePe Edition - Windows Installer
REM  New, simplified version based on install.command
REM  Target: fresh Windows 10/11 device with winget available
REM =======================================================

REM Always run from the directory where this script is located
cd /d "%~dp0"

title Scammer Hunter - PhonePe Edition - Windows Setup (New)

echo ========================================
echo       Scammer Hunter - PhonePe
echo        Windows Installer (New)
echo ========================================
echo.
echo ^>^>^> This will set up everything automatically! ^<^<^<
echo.
echo Requirements:
echo   - Windows 10/11 with winget available
echo   - Internet connection
echo   - It is recommended to Run as Administrator
echo.

REM --------------------
REM Check for winget (Windows Package Manager)
REM --------------------
winget --version >nul 2>&1
IF ERRORLEVEL 1 GOTO NoWinget

echo [OK] winget is available.
echo.
GOTO AfterWinget

:NoWinget
echo [WARN] winget (Windows Package Manager) is not available on this system.
echo.
echo [INFO] Attempting to open the Microsoft Store page for "App Installer"
echo        (which includes winget). Please install it from there.
echo.
echo If the Store does not open, you can manually visit:
echo   https://learn.microsoft.com/windows/package-manager/winget/
echo or search for "App Installer" in Microsoft Store.
echo.
start "" "ms-windows-store://pdp/?productid=9NBLGGH4NNS1"
echo After installing App Installer / winget, re-run this script.
echo.
pause
GOTO :EOF

:AfterWinget

REM --------------------
REM Check / install Python
REM --------------------
echo [CHECK] Looking for Python...
python --version >nul 2>&1
if errorlevel 1 (
    echo [INFO] Python not found. Installing Python via winget...
    winget install -e --id Python.Python.3.13 --accept-package-agreements --accept-source-agreements
    if errorlevel 1 (
        echo [ERROR] winget failed to install Python.
        echo Please install Python 3 manually from https://python.org and re-run this script.
        echo.
        pause
        goto :EOF
    )
    echo [INFO] Python installed. Updating PATH for current session...
    REM Common install path; may vary, but python launcher usually updates PATH
    set "PATH=%ProgramFiles%\Python313;%ProgramFiles%\Python313\Scripts;%PATH%"
) else (
    echo [OK] Python already installed.
)
echo.

REM --------------------
REM Check / install ngrok
REM --------------------
echo [CHECK] Looking for ngrok...
ngrok version >nul 2>&1
if errorlevel 1 (
    echo [INFO] ngrok not found. Installing ngrok via winget...
    winget install -e --id Ngrok.ngrok --accept-package-agreements --accept-source-agreements
    if errorlevel 1 (
        echo [ERROR] winget failed to install ngrok.
        echo Please install ngrok manually from https://ngrok.com and re-run this script.
        echo.
        pause
        goto :EOF
    )
) else (
    echo [OK] ngrok already installed.
)
echo.

REM --------------------
REM Install Python packages
REM --------------------
echo [INFO] Installing required Python packages...
python -m pip install --upgrade pip >nul 2>&1

if exist "requirements.txt" (
    echo [INFO] Using requirements.txt
    python -m pip install -r requirements.txt
) else (
    echo [INFO] Installing packages directly: flask, requests, pyngrok
    python -m pip install flask requests pyngrok
)

if errorlevel 1 (
    echo [ERROR] Python package installation failed. Please check your internet connection and try again.
    echo.
    pause
    goto :EOF
)

echo.
echo =========================================
echo      NGROK AUTH TOKEN SETUP
echo =========================================
echo.
echo You need a ngrok auth token for public URLs.
echo.
echo Get it here: https://dashboard.ngrok.com/get-started/your-authtoken
echo (Sign up for free, then copy your token)
echo.
set "NGROK_TOKEN="
set /p NGROK_TOKEN="Paste your ngrok auth token: "

if "%NGROK_TOKEN%"=="" (
    echo [ERROR] No token entered. Setup cancelled.
    echo.
    pause
    goto :EOF
)

echo.
echo [INFO] Setting up ngrok authentication...
ngrok config add-authtoken "%NGROK_TOKEN%"
if errorlevel 1 (
    echo [ERROR] ngrok authentication failed. Please verify your token and try again.
    echo.
    pause
    goto :EOF
)

echo.
echo =========================================
echo         STARTING SCAM CATCHER!
echo =========================================
echo.

REM NOTE: We intentionally avoid aggressive port-kill logic here
REM to prevent parsing issues. If port 8080 is already in use,
REM Flask will print an error in the server window.

echo [INFO] Starting Flask server in a new window...
start "PhonePe Scam Catcher" cmd /k "%~dp0start_server.bat"

echo.
echo =========================================
echo        SETUP COMPLETE (WINDOWS)
echo =========================================
echo.
echo [OK] Flask server and ngrok tunnel are starting in the new window.
echo.
echo Send this to scammers via WhatsApp:
echo   "Please share your UPI QR code here: [COPY_URL_FROM_SERVER_WINDOW]"
echo.
echo Photos will save to: %cd%\captured_photos\
echo.
echo To stop: Close the server window or press Ctrl+C in it.
echo.
echo =========================================
echo      HAPPY HUNTING!
echo =========================================
echo.
echo Press any key to exit this setup window...
pause >nul

endlocal
exit /b

