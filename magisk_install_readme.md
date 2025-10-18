# Android 16 Linux Terminal VM Persistence Module

## What This Does

Android 16's Linux Terminal runs a Debian VM using the Android Virtualization Framework (AVF). The VM is managed by `VirtualizationService` and runs through `crosvm`. By default:

1. **The VM stops when you close the Terminal app** - The VM lifecycle is tied to binder references held by the app
2. **The VM can be killed by Android** - Low memory killer can terminate crosvm processes
3. **The VM doesn't auto-start** - You must manually launch the Terminal app

This Magisk module solves these issues by:
- Keeping the Terminal app running in the background
- Protecting crosvm processes from the OOM (Out of Memory) killer
- Monitoring and restarting components if they stop
- Auto-starting everything on boot

## Requirements

- **Android 16** (or Android 15 with Terminal backported, like GrapheneOS)
- **Root access** (Magisk/KernelSU)
- **AVF support** - Your device must support Android Virtualization Framework
- **Terminal app enabled** - Enable "Linux development environment" in Developer Options

**Note**: Samsung devices with Knox may not support AVF properly.

## Installation

1. **Create the module structure:**
```
terminal_vm_persist/
├── module.prop
├── service.sh
└── uninstall.sh
```

2. **Set proper permissions:**
   - All `.sh` files must be executable (chmod 755)

3. **Package as ZIP:**
```bash
cd terminal_vm_persist
zip -r terminal_vm_persist.zip .
```

4. **Install via Magisk:**
   - Open Magisk Manager
   - Modules → Install from storage
   - Select the ZIP file
   - Reboot

## How It Works

The module runs a background service that:

1. **Monitors the Terminal app** - Ensures it stays running
2. **Protects crosvm** - Sets OOM score to -1000 (highest protection)
3. **Protects Terminal app** - Sets OOM score to -800
4. **Continuous monitoring** - Checks every 30 seconds

## Verification

Check if the service is working:
```bash
# Check service logs
logcat -s Terminal-Persist

# Check if crosvm is protected
ps -A | grep crosvm
cat /proc/$(pidof crosvm)/oom_score_adj  # Should show -1000

# Check Terminal app
ps -A | grep terminal
```

## Limitations

1. **This keeps the app running**, not just the VM - The VM lifecycle is tightly coupled to the app
2. **Battery impact** - The Terminal app and VM will run continuously
3. **System permission required** - The MANAGE_VIRTUAL_MACHINE permission is restricted
4. **Device compatibility** - Some OEMs may block or restrict AVF

## Advanced: Direct VM Management

For more control, you can interact with VirtualizationService directly:

```bash
# List running VMs
/apex/com.android.virt/bin/vm list

# Get VM info
ls -la /data/data/com.android.virtualization.terminal/vm/

# Check VM logs
cat /data/data/com.android.virtualization.terminal/files/debian.log
```

## Troubleshooting

**VM still stops:**
- Check if Terminal app has battery optimization disabled
- Verify AVF is actually working: `ls /dev/kvm`
- Check for Knox restrictions (Samsung devices)

**High battery drain:**
- This is expected - you're running a full Linux VM
- Consider only enabling persistence when needed

**Permission errors:**
- Ensure you're running a userdebug or eng build for full access
- Some functionality requires SELinux permissive mode

## Uninstall

Remove the module from Magisk Manager, or run the uninstall script manually:
```bash
su -c /data/adb/modules/terminal_vm_persist/uninstall.sh
```

## Technical Details

- **Package**: `com.android.virtualization.terminal`
- **VM Manager**: `/apex/com.android.virt/bin/vm`
- **Data location**: `/data/data/com.android.virtualization.terminal/`
- **VM Image**: `/sdcard/linux/images.tar.gz` (if custom)

## Alternative Approaches

If this module doesn't work for your use case:
1. **Foreground notification** - Keep Terminal app in foreground with persistent notification
2. **Boot script** - Use init.d or boot script to start VM
3. **Custom system service** - Create a dedicated system service (requires building ROM)