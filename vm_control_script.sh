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
    
    # Protect Terminal app too
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

# Main script
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