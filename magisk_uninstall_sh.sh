#!/system/bin/sh
# Magisk Module Uninstall Script

# Kill the terminal service
if [ -f /data/local/tmp/terminal_service.pid ]; then
    PID=$(cat /data/local/tmp/terminal_service.pid)
    kill -9 $PID 2>/dev/null
    rm /data/local/tmp/terminal_service.pid
fi

# Kill any keep_alive processes
killall -9 keep_alive 2>/dev/null
