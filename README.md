# Android 16 Linux Terminal VM Persistence

A Magisk module that keeps Android 16's native Linux Terminal VM running persistently, preventing Android from killing it.

## 📋 Overview

Android 16 introduced a native Linux Terminal that runs a full Debian virtual machine using the Android Virtualization Framework (AVF). By default, this VM has two major issues:

1. **Closes when you exit the app** - The VM lifecycle is tied to the Terminal app
2. **Gets killed by Android** - The low memory killer can terminate the VM process

This Magisk module solves both problems by keeping the Terminal app running in the background and protecting the VM from being killed.

## 🎯 Features

- ✅ Keeps Terminal VM running 24/7
- ✅ Protects `crosvm` processes from OOM killer (score: -1000)
- ✅ Auto-starts on boot
- ✅ Monitors and restarts if stopped
- ✅ Includes control script for manual management
- ✅ Minimal battery impact optimization

## 📱 Requirements

| Requirement | Details |
|-------------|---------|
| **Android Version** | Android 16+ (or Android 15 with Terminal backport) |
| **Root** | Magisk 20.4+ or KernelSU |
| **AVF Support** | Device must support Android Virtualization Framework |
| **Terminal Enabled** | Enable in Developer Options → Linux development environment |

### ⚠️ Known Incompatibilities

- **Samsung devices** with Knox may not support AVF properly
- Devices without `/dev/kvm` support
- Some custom ROMs that modify AVF

## 📦 Installation

### Quick Install

1. **Download** the latest release or create the module:

```bash
# Clone or download these files
VM_Magisk_Module/
├── module.prop
├── service.sh
├── uninstall.sh
├── vm_control.sh
└── system.prop
```

2. **Package the module:**

```bash
cd VM_Magisk_Module
zip -r terminal_vm_persist.zip .
```

3. **Install via Magisk:**
   - Open Magisk Manager
   - Go to **Modules** → **Install from storage**
   - Select `terminal_vm_persist.zip`
   - Reboot your device

### Manual Installation

```bash
# Push files to Magisk modules directory
adb push VM_Magisk_Module /data/adb/modules/

# Set proper permissions
adb shell
su
cd /data/adb/modules/VM_Magisk_Module
chmod 755 *.sh
reboot
```

## 🚀 Usage

### Automatic Operation

After installation and reboot, the module runs automatically. The Terminal VM will:
- Start on boot
- Stay running in background
- Restart automatically if stopped
- Be protected from memory management

### Manual Control

Use the included control script for manual management:

```bash
# Check VM status
su -c /data/adb/modules/VM_Magisk_Module/vm_control.sh status

# Protect processes immediately
su -c /data/adb/modules/VM_Magisk_Module/vm_control.sh protect

# Start Terminal app
su -c /data/adb/modules/VM_Magisk_Module/vm_control.sh start

# View VM information
su -c /data/adb/modules/VM_Magisk_Module/vm_control.sh info

# Show VM logs
su -c /data/adb/modules/VM_Magisk_Module/vm_control.sh logs

# Force restart Terminal
su -c /data/adb/modules/VM_Magisk_Module/vm_control.sh force-restart
```

## 🔍 Verification

### Check if the module is working:

```bash
# View service logs
logcat -s Terminal-Persist

# Check crosvm protection
ps -A | grep crosvm
cat /proc/$(pidof crosvm)/oom_score_adj
# Should output: -1000

# Check Terminal app status
ps -A | grep terminal

# List running VMs
/apex/com.android.virt/bin/vm list
```

### Expected Output

```
Terminal app: RUNNING (PID: 12345)
OOM score: -800

VMs running:
  crosvm (PID: 12346)
  OOM score: -1000
```

## 🛠️ How It Works

### Technical Details

The module leverages the Android Virtualization Framework's architecture:

1. **VM Lifecycle Management**
   - VirtualizationService manages VMs through `IVirtualMachine` binder objects
   - When all binder references are dropped, the VM shuts down
   - Keeping the Terminal app alive maintains the binder reference

2. **OOM Protection**
   - Sets `oom_score_adj` to `-1000` for crosvm processes
   - Sets `oom_score_adj` to `-800` for Terminal app
   - Prevents Android's low memory killer from terminating them

3. **Continuous Monitoring**
   - Background service checks every 30 seconds
   - Restarts Terminal app if stopped
   - Re-applies OOM protection if needed

### File Locations

```
Terminal Package:     com.android.virtualization.terminal
VM Command:          /apex/com.android.virt/bin/vm
Data Directory:      /data/data/com.android.virtualization.terminal/
VM Images:           /sdcard/linux/images.tar.gz (optional custom)
Logs:                /data/data/com.android.virtualization.terminal/files/
```

## 🔧 Troubleshooting

### VM Still Stops

**Check AVF support:**
```bash
# Verify KVM device exists
ls -l /dev/kvm

# Check virtualization APEX
ls -l /apex/com.android.virt
```

**Disable battery optimization:**
- Settings → Apps → Terminal → Battery → Unrestricted

**Check for Knox restrictions (Samsung):**
```bash
getprop ro.boot.warranty_bit
# 0 = Knox intact, 1 = Knox tripped
```

### High Battery Drain

This is expected when running a full Linux VM continuously. To reduce:

1. **Limit VM resources** in Terminal settings
2. **Reduce disk size** to minimum needed
3. **Disable unused services** inside the VM
4. **Only enable when needed** - disable module when not in use

### Permission Errors

Some operations require additional access:

```bash
# Enable debuggable mode (if needed)
su -c "magisk resetprop ro.debuggable 1; stop; start"

# Check SELinux status
getenforce
# If "Enforcing" is causing issues, can temporarily set to Permissive (not recommended)
```

### Service Not Starting

```bash
# Check module installation
ls -l /data/adb/modules/VM_Magisk_Module/

# Verify file permissions
ls -l /data/adb/modules/VM_Magisk_Module/*.sh

# Check service logs
logcat -s Terminal-Persist

# Manually start service
su -c "/data/adb/modules/VM_Magisk_Module/service.sh &"
```

## ⚠️ Limitations

1. **Battery Impact** - Running a VM 24/7 consumes battery
2. **App Coupling** - Must keep entire Terminal app running, not just VM
3. **System Permissions** - MANAGE_VIRTUAL_MACHINE permission is restricted
4. **Device Support** - Limited to AVF-compatible devices
5. **Memory Usage** - VM consumes RAM continuously (typically 512MB-2GB)

## 🔄 Alternative Approaches

If this module doesn't work for your needs:

### 1. Foreground Service Notification
Keep Terminal in foreground with persistent notification (no root required)

### 2. Tasker/Automation
Use automation apps to restart Terminal periodically

### 3. Custom System Service
Build your own ROM with a dedicated system service for the VM

### 4. Direct VM Management
Use `vm` command with custom scripts:
```bash
/apex/com.android.virt/bin/vm run /data/local/tmp/vm_config.json
```

## 🗑️ Uninstallation

### Via Magisk Manager
1. Open Magisk Manager
2. Go to Modules
3. Remove "Android 16 Terminal VM Persistence"
4. Reboot

### Manual Cleanup
```bash
su
/data/adb/modules/VM_Magisk_Module/uninstall.sh
rm -rf /data/adb/modules/VM_Magisk_Module
reboot
```

## 📚 Additional Resources

- [Android Virtualization Framework Documentation](https://source.android.com/docs/core/virtualization)
- [AVF Architecture Details](https://source.android.com/docs/core/virtualization/architecture)
- [VirtualizationService API](https://source.android.com/docs/core/virtualization/virtualization-service)
- [Crosvm Documentation](https://android.googlesource.com/platform/external/crosvm/)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## 📄 License

This project is provided as-is for educational purposes. Use at your own risk.

## ⚡ Credits

- Android Virtualization Framework by Google
- Magisk by topjohnwu
- NixOS-AVF project for research insights

---

**Note:** This module is for advanced users who understand the implications of running persistent VMs on Android. Always backup your data before installation.
