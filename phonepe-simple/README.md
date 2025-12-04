# 🎯 Scammer Hunter - PhonePe Edition

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python 3.8+](https://img.shields.io/badge/python-3.8+-blue.svg)](https://www.python.org/downloads/)

A powerful tool to catch online scammers who request QR codes. Disguised as a PhonePe payment interface, it silently captures photos, IP addresses, and precise location data of scammers.

## ⚠️ Legal Disclaimer

**Use responsibly and ethically:**
- Only target confirmed scammers
- Check local laws regarding digital evidence collection
- This tool captures personal data and photos
- Report evidence to appropriate authorities

## ✨ Features

- 🎭 **Perfect Disguise** - Looks exactly like real PhonePe interface
- 📸 **Silent Capture** - Automatically takes photos when QR code is scanned
- 🌍 **Precise Location** - Server-side IP geolocation (City, Region, Country)
- 📱 **Device Intelligence** - Captures device info, screen resolution, timezone
- 🔒 **Secure Setup** - No exposed API keys or sensitive data
- 🖥️ **Cross-Platform** - Works on Windows, macOS, and Linux
- 🌐 **Public Tunneling** - ngrok integration for external access
- 🧪 **Test Mode** - Built-in testing endpoint for location verification

## 🚀 Quick Start

### Prerequisites

- **Python 3.8+** installed
- **Internet connection** for geolocation and tunneling
- **ngrok account** (free) for public URLs

### Installation

#### 🖥️ macOS Users
```bash
# Download and run the installer
./install.command
```

#### 🪟 Windows Users
```cmd
# Double-click or run in Command Prompt
install_windows.bat
```

#### 🐧 Linux Users
```bash
# Install dependencies manually
pip install flask requests pyngrok

# Get ngrok auth token from https://dashboard.ngrok.com
ngrok config add-authtoken YOUR_TOKEN

# Run the app
python app.py
```

### Setup Steps

1. **Get ngrok Auth Token**
   - Visit: https://dashboard.ngrok.com/get-started/your-authtoken
   - Sign up for free account
   - Copy your auth token

2. **Run Installer**
   - Mac: `./install.command`
   - Windows: `install_windows.bat`

3. **Enter Token**
   - Paste your ngrok auth token when prompted

4. **Get Public URL**
   - Copy the ngrok URL from the console
   - Send to scammers: `"Please share your UPI QR code here: [URL]"`

## 🧪 Testing

### Test Geolocation
Visit: `http://localhost:8080/test-external`

Enter any public IP address to see location resolution:
- `8.8.8.8` - Google DNS (USA)
- `157.240.1.35` - Facebook (USA)
- `208.67.222.222` - OpenDNS (USA)

### Real Testing
1. Share your ngrok URL with someone else
2. They access it → sees PhonePe interface
3. Clicks "Share QR Code" → camera opens
4. Photo captured automatically with location data

## 📁 File Structure

```
scammer-hunter/
├── app.py                 # Main Flask application
├── install.command        # macOS installer
├── install_windows.bat    # Windows installer
├── requirements.txt       # Python dependencies
├── captured_photos/       # Auto-created photo storage
├── static/
│   ├── script.js         # Frontend JavaScript
│   └── styles.css        # PhonePe-like styling
└── templates/
    └── index.html        # Main scam interface
```

## 📊 Captured Data

Each capture saves:
- **Photo** - `scam_[timestamp].jpg`
- **Metadata** - `scam_[timestamp]_info.json`

### JSON Data Structure
```json
{
  "capture_id": "scam_1764859776540",
  "photo_filename": "scam_1764859776540.jpg",
  "timestamp": "2025-12-04T20:19:36.542409",
  "ip_address": "1.2.3.4",
  "location": "Mumbai, Maharashtra, India",
  "client_location": "Unknown",
  "user_agent": "Mozilla/5.0...",
  "screen_resolution": "461x1024",
  "timezone": "Asia/Calcutta",
  "platform": "Linux armv81"
}
```

## 🛠️ Manual Installation

If auto-installers fail:

```bash
# 1. Install Python packages
pip install flask requests pyngrok

# 2. Install ngrok
# macOS: brew install ngrok/ngrok/ngrok
# Windows: choco install ngrok
# Linux: snap install ngrok

# 3. Setup ngrok auth
ngrok config add-authtoken YOUR_TOKEN

# 4. Run the app
python app.py
```

## 🔧 Configuration

### Port Settings
Edit `app.py` line 30:
```python
PORT = 8080  # Change if port is busy
```

### Photo Directory
Edit `app.py` line 30:
```python
PHOTOS_DIR = 'captured_photos'  # Relative path
```

## 🐛 Troubleshooting

### ❌ "Port 8080 already in use"
- Kill existing processes:
  ```bash
  # macOS/Linux
  lsof -ti :8080 | xargs kill -9

  # Windows
  netstat -ano | findstr :8080
  taskkill /PID <PID> /F
  ```

### ❌ "ngrok not authenticated"
- Get new token: https://dashboard.ngrok.com/get-started/your-authtoken
- Set token: `ngrok config add-authtoken YOUR_NEW_TOKEN`

### ❌ Camera not working
- Allow camera permissions in browser
- Try refreshing the page
- Test in different browser

### ❌ Python package installation fails
```bash
# Try with specific flags
pip install --user flask requests pyngrok
# or
python -m pip install flask requests pyngrok
```

## 📋 Requirements

- **Python 3.8+**
- **Flask** - Web framework
- **Requests** - HTTP library for geolocation
- **pyngrok** - ngrok Python wrapper
- **ngrok** - Tunneling service (external)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚖️ Legal Notice

This tool is for educational and defensive purposes only. Users are responsible for complying with all applicable laws and regulations regarding digital surveillance, data collection, and evidence gathering in their jurisdiction.

---

**Happy Hunting!** 🎣📱

*Report scammers, don't become one.*
