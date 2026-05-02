#!/bin/bash
# Optimized for Ubuntu 24.04 Noble Numbat (MATE/X11)

set -e

echo "[1/5] Installing Weston and dependencies..."
sudo apt update
sudo apt install -y weston waydroid mesa-utils curl

echo "[2/5] Cleaning up lingering network locks..."
# Clears the "Address already in use" error for 192.168.240.1
sudo pkill -9 dnsmasq || true
sudo ip link delete waydroid0 || true

echo "[3/5] Initializing Waydroid (Android 13 Images)..."
# Using Android 13 (Lineage 20) images as referenced in your logs
if [ ! -d "/var/lib/waydroid/cells" ]; then
    sudo waydroid init -s GAPPS -f
else
    echo "Waydroid already initialized."
fi

echo "[4/5] Applying Software Rendering Props..."
# Essential for your software rendering setup
sudo mkdir -p /var/lib/waydroid/
echo "ro.hardware.egl=swiftshader" | sudo tee /var/lib/waydroid/waydroid_base.prop
echo "ro.hardware.gralloc=default" | sudo tee -a /var/lib/waydroid/waydroid_base.prop

echo "[5/5] Starting services and creating launcher..."
sudo systemctl enable --now waydroid-container

# Create the launch wrapper
cat << 'EOF' > start_android.sh
#!/bin/bash
# 1. Launch Weston as a nested window in MATE (X11)
weston --width=1280 --height=720 --shell=desktop-shell.so &
W_PID=$!

# 2. Give Weston time to create wayland-1
sleep 3

# 3. Start Waydroid session directed at the Weston window
WAYLAND_DISPLAY=wayland-1 waydroid show-full-ui &

# 4. Cleanup when finished
trap "kill $W_PID; exit" SIGINT SIGTERM
wait
EOF

chmod +x start_android.sh
echo "Setup complete. Run ./start_android.sh to begin."
