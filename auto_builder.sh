#!/bin/bash
# Automatic Module Builder - Creates complete Magisk module
# This script contains all file contents and creates the ZIP automatically

set -e

MODULE_DIR="terminal_vm_persist"
OUTPUT_ZIP="terminal_vm_persist.zip"

echo "==========================================="
echo "Terminal VM Persistence - Auto Builder"
echo "==========================================="
echo ""

# Clean up existing directory/zip
if [ -d "$MODULE_DIR" ]; then
    echo "Removing existing directory..."
    rm -rf "$MODULE_DIR"
fi

if [ -f "$OUTPUT_ZIP" ]; then
    echo "Removing existing ZIP..."
    rm "$OUTPUT_ZIP"
fi

# Create directory
echo "Creating module directory..."
mkdir -p "$MODULE_DIR"
cd "$MODULE_DIR"

# Create module.prop
echo "Creating module.prop..."
cat > module.prop << 'MODPROP'
id=terminal_vm_persist
name=Android 16 Terminal VM Persistence
version=1.0
versionCode=1
author=AVF Enthusiast
description=Keeps Android 16 Linux Terminal VM running persistently by protecting it from OOM killer and keeping the app alive
MODPROP

# Create service.sh
echo "Creating service.sh..."
cat > service.sh << 'SERVICEEOF'
#!/system/bin/sh
# Terminal VM Persistence Service

MODDIR=${0%/*}
TERMINAL_PKG="com.android.virtualization.terminal"
TERMINAL_ACTIVITY="com.android.virtualization.terminal.MainActivity"
VIRT_SERVICE="/apex/com.android.virt/bin/vm"

# Wait for boot
while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 1
done
sleep 10

log_msg() {
    echo "[Terminal-Persist] $1"
    log -t Terminal-Persist "$1"
}

# Protect crosvm processes from OOM killer
protect_crosvm() {
    for pid in $(pgrep -f crosvm); do
        if [ -d /proc/$pid ]; then
            echo -1000 > /proc/$pid/oom_score_adj 2>/dev/null
            log_msg "Protected crosvm PID $pid from OOM killer"
        fi
    done
}

# Keep Terminal app running in background
keep_terminal_alive() {
    # Check if Terminal app is running
    if ! pidof $TERMINAL_PKG > /dev/null 2>&1; then
        log_msg "Starting Terminal app..."
        # Start the activity in background
        am start -n $TERMINAL_PKG/$TERMINAL_ACTIVITY > /dev/null 2>&1
        sleep 5
    fi
    
    # Protect the Terminal app from being killed
    TERMINAL_PID=$(pidof $TERMINAL_PKG)
    if [ -n "$TERMINAL_PID" ]; then
        echo -800 > /proc/$TERMINAL_PID/oom_score_adj 2>/dev/null
        log_msg "Protected Terminal app PID $TERMINAL_PID"
    fi
}

# Monitor and protect VMs continuously
monitor_vms() {
    while true; do
        # Protect any running crosvm processes
        protect_crosvm
        
        # Keep Terminal app alive
        keep_terminal_alive
        
        # Sleep before next check
        sleep 30
    done
}

log_msg "Service started - monitoring Linux Terminal VM"

# Start monitoring in background
monitor_vms &

# Keep service running
wait
SERVICEEOF

# Create uninstall.sh
echo "Creating uninstall.sh..."
cat > uninstall.sh << 'UNINSTALLEOF'
#!/system/bin/sh
# Terminal VM Persistence - Uninstall Script

TERMINAL_PKG="com.android.virtualization.terminal"

echo "Cleaning up Terminal VM Persistence module..."

# Stop Terminal app
am force-stop $TERMINAL_PKG 2>/dev/null

# Kill monitoring service
pkill -f "Terminal-Persist" 2>/dev/null

echo "Cleanup complete"
UNINSTALLEOF

# Create vm_control.sh
echo "Creating vm_control.sh..."
cat > vm_control.sh << 'VMCONTROLEOF'
#!/system/bin/sh
# VM Control Script - Manage Android Terminal VM

TERMINAL_PKG="com.android.virtualization.terminal"
VM_CMD="/apex/com.android.virt/bin/vm"
DATA_DIR="/data/data/$TERMINAL_PKG"

print_usage() {
    echo "Android Terminal VM Control"
    echo ""
    echo "Usage: vm_control.sh [command]"
    echo ""
    echo "Commands:"
    echo "  status        - Show VM and app status"
    echo "  protect       - Protect crosvm from OOM killer"
    echo "  start         - Start Terminal app"
    echo "  info          - Show VM information"
    echo "  logs          - Show VM logs"
    echo "  force-restart - Force restart Terminal app"
    echo ""
}

check_root() {
    if [ "$(id -u)" != "0" ]; then
        echo "Error: This script requires root access"
        exit 1
    fi
}

show_status() {
    echo "=== Terminal App Status ==="
    if pidof $TERMINAL_PKG > /dev/null 2>&1; then
        TERM_PID=$(pidof $TERMINAL_PKG)
        echo "Terminal app: RUNNING (PID: $TERM_PID)"
        if [ -f /proc/$TERM_PID/oom_score_adj ]; then
            OOM_SCORE=$(cat /proc/$TERM_PID/oom_score_adj)
            echo "OOM score: $OOM_SCORE"
        fi
    else
        echo "Terminal app: NOT RUNNING"
    fi
    
    echo ""
    echo "=== VM Status ==="
    if pgrep -f crosvm > /dev/null 2>&1; then
        echo "VMs running:"
        ps -A | grep crosvm | while read line; do
            echo "  $line"
            VM_PID=$(echo $line | awk '{print $2}')
            if [ -f /proc/$VM_PID/oom_score_adj ]; then
                OOM_SCORE=$(cat /proc/$VM_PID/oom_score_adj)
                echo "    OOM score: $OOM_SCORE"
            fi
        done
    else
        echo "No VMs running"
    fi
    
    echo ""
    echo "=== AVF Status ==="
    if [ -e /dev/kvm ]; then
        echo "KVM device: AVAILABLE"
    else
        echo "KVM device: NOT AVAILABLE"
    fi
    
    if [ -d /apex/com.android.virt ]; then
        echo "Virtualization APEX: INSTALLED"
    else
        echo "Virtualization APEX: NOT FOUND"
    fi
}

protect_vms() {
    echo "Protecting crosvm processes from OOM killer..."
    protected=0
    for pid in $(pgrep -f crosvm); do
        if [ -d /proc/$pid ]; then
            echo -1000 > /proc/$pid/oom_score_adj 2>/dev/null
            echo "Protected PID $pid"
            protected=$((protected + 1))
        fi
    done
    
    if [ $protected -eq 0 ]; then
        echo "No crosvm processes found"
    else
        echo "Protected $protected process(es)"
    fi
    
    TERM_PID=$(pidof $TERMINAL_PKG)
    if [ -n "$TERM_PID" ]; then
        echo -800 > /proc/$TERM_PID/oom_score_adj 2>/dev/null
        echo "Protected Terminal app PID $TERM_PID"
    fi
}

start_terminal() {
    echo "Starting Terminal app..."
    am start -n $TERMINAL_PKG/.MainActivity
    sleep 3
    if pidof $TERMINAL_PKG > /dev/null 2>&1; then
        echo "Terminal app started successfully"
        protect_vms
    else
        echo "Failed to start Terminal app"
    fi
}

show_vm_info() {
    echo "=== VM Information ==="
    if [ -x "$VM_CMD" ]; then
        $VM_CMD list 2>/dev/null || echo "No VMs found or vm command not available"
    else
        echo "VM command not found at $VM_CMD"
    fi
    
    echo ""
    echo "=== VM Data Directory ==="
    if [ -d "$DATA_DIR" ]; then
        ls -lh "$DATA_DIR/vm/" 2>/dev/null
    else
        echo "Data directory not found"
    fi
}

show_logs() {
    echo "=== VM Logs ==="
    if [ -d "$DATA_DIR/files" ]; then
        for log in "$DATA_DIR/files/"*.log; do
            if [ -f "$log" ]; then
                echo ""
                echo "--- $(basename $log) ---"
                tail -50 "$log"
            fi
        done
    else
        echo "Log directory not found"
    fi
}

force_restart() {
    echo "Force restarting Terminal app..."
    am force-stop $TERMINAL_PKG
    sleep 2
    start_terminal
}

check_root

case "$1" in
    status)
        show_status
        ;;
    protect)
        protect_vms
        ;;
    start)
        start_terminal
        ;;
    info)
        show_vm_info
        ;;
    logs)
        show_logs
        ;;
    force-restart)
        force_restart
        ;;
    *)
        print_usage
        exit 1
        ;;
esac
VMCONTROLEOF

# Create system.prop
echo "Creating system.prop..."
cat > system.prop << 'SYSPROPEOF'
# Terminal VM Persistence Configuration

# Note: Most configurations should be done through
# Developer Options > Linux development environment settings
SYSPROPEOF

# Set proper permissions
echo "Setting permissions..."
chmod 644 module.prop
chmod 755 service.sh
chmod 755 uninstall.sh
chmod 755 vm_control.sh
chmod 644 system.prop

cd ..

# Create ZIP
echo ""
echo "Creating ZIP file..."
cd "$MODULE_DIR"
zip -r9 "../$OUTPUT_ZIP" . > /dev/null
cd ..

# Verify
if [ -f "$OUTPUT_ZIP" ]; then
    echo ""
    echo "==========================================="
    echo "SUCCESS!"
    echo "==========================================="
    echo ""
    echo "Created: $OUTPUT_ZIP"
    echo "Size: $(du -h "$OUTPUT_ZIP" | cut -f1)"
    echo ""
    echo "Contents:"
    unzip -l "$OUTPUT_ZIP"
    echo ""
    echo "Next steps:"
    echo "1. Transfer $OUTPUT_ZIP to your Android device"
    echo "2. Open Magisk Manager"
    echo "3. Go to Modules → Install from storage"
    echo "4. Select $OUTPUT_ZIP"
    echo "5. Reboot device"
    echo ""
    echo "After reboot, verify with:"
    echo "  su -c /data/adb/modules/terminal_vm_persist/vm_control.sh status"
    echo ""
else
    echo "ERROR: Failed to create ZIP file"
    exit 1
fi