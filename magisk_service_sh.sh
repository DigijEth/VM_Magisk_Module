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