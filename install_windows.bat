@echo off
REM Scammer Hunter - PhonePe Edition - Windows Installer
REM For Windows users only

title Scammer Hunter - PhonePe Edition - Windows Setup

echo ========================================
echo       Scammer Hunter - PhonePe
echo          Windows Installer
echo ========================================
echo.
echo ^>^>^> This will set up everything automatically! ^<^<^<
echo.
echo Requirements: Internet connection, Administrator privileges recommended
echo.

REM Check if Chocolatey is installed
choco --version >nul 2>&1
if %errorlevel% neq 0 (
    echo 📦 Installing Chocolatey (package manager)...
    echo Please run this script as Administrator if you haven't installed Chocolatey yet.
    echo You can install Chocolatey manually from: https://chocolatey.org/install
    echo Then re-run this script.
    pause
    exit /b 1
)

echo ✅ Chocolatey ready!

REM Check if Python is installed
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo 🐍 Installing Python...
    choco install python -y
    if %errorlevel% neq 0 (
        echo ❌ Python installation failed. Please install Python manually from https://python.org
        pause
        exit /b 1
    )
    REM Refresh environment variables
    call refreshenv.cmd >nul 2>&1
) else (
    echo ✅ Python already installed!
)

REM Install ngrok
ngrok version >nul 2>&1
if %errorlevel% neq 0 (
    echo 🌐 Installing ngrok...
    choco install ngrok -y
    if %errorlevel% neq 0 (
        echo ❌ ngrok installation failed. Please install ngrok manually from https://ngrok.com
        pause
        exit /b 1
    )
) else (
    echo ✅ ngrok already installed!
)

REM Install Python packages
echo 📦 Installing Python packages...
pip install flask requests pyngrok
if %errorlevel% neq 0 (
    echo ❌ Python package installation failed. Please check your internet connection.
    pause
    exit /b 1
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
set /p NGROK_TOKEN="Paste your ngrok auth token: "

if "%NGROK_TOKEN%"=="" (
    echo ❌ No token entered. Setup cancelled.
    pause
    exit /b 1
)

echo 🔑 Setting up ngrok authentication...
ngrok config add-authtoken %NGROK_TOKEN%
if %errorlevel% neq 0 (
    echo ❌ ngrok authentication failed. Please check your token.
    pause
    exit /b 1
)

echo.
echo =========================================
echo         STARTING SCAM CATCHER!
echo =========================================
echo.

REM Kill any existing processes using port 8080
echo 🧹 Cleaning up any existing processes...
for /f "tokens=5" %%a in ('netstat -ano ^| find "8080" ^| find "LISTENING"') do (
    echo 🔪 Killing process on port 8080 (PID: %%a)...
    taskkill /PID %%a /F >nul 2>&1
)

REM Kill any existing Python processes running app.py
tasklist /FI "IMAGENAME eq python.exe" /FI "WINDOWTITLE eq app.py" >nul 2>&1
if %errorlevel% equ 0 (
    echo 🔪 Killing existing app.py processes...
    taskkill /FI "IMAGENAME eq python.exe" /FI "WINDOWTITLE eq app.py" /F >nul 2>&1
)

REM Wait a moment for cleanup
timeout /t 2 /nobreak >nul

REM Start Flask server in background
echo 🚀 Starting Flask server...
start "PhonePe Scam Catcher" cmd /c "python app.py"

REM Wait for Flask and ngrok to start
echo Waiting for server to start...
timeout /t 8 /nobreak >nul

echo.
echo =========================================
echo        🎉 SETUP COMPLETE! 🎉
echo =========================================
echo.
echo ✅ Flask server and ngrok tunnel started!
echo 📱 Check the new command window for your public URL
echo.
echo 📤 Send this to scammers via WhatsApp:
echo "Please share your UPI QR code here: [COPY_URL_FROM_SERVER_WINDOW]"
echo.
echo 📸 Photos will save to: %cd%\captured_photos\
echo.
echo 🛑 To stop: Close the server window or press Ctrl+C in it
echo.
echo =========================================
echo      HAPPY HUNTING! 🎣📱
echo =========================================

REM Keep window open
echo.
echo Press any key to exit this setup window...
pause >nul
