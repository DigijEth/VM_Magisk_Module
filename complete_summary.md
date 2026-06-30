# Complete File List for Magisk Module

## Three Ways to Create the Module

### Method 1: Automatic (Easiest) ⭐ RECOMMENDED

1. **Download:** `auto_create_module.sh`
2. **Run:**
   ```bash
   chmod +x auto_create_module.sh
   ./auto_create_module.sh
   ```
3. **Done!** The script creates `terminal_vm_persist.zip` automatically

---

### Method 2: Manual with Build Script

1. **Create these 6 files manually** (copy content from artifacts below)
2. **Run:** `build_module.sh` to create ZIP
3. **Install** the generated ZIP

---

### Method 3: Completely Manual

1. **Create directory:** `terminal_vm_persist/`
2. **Copy all 6 required file contents** into that directory
3. **Set permissions:** `chmod 755 *.sh`
4. **Create ZIP:** `zip -r terminal_vm_persist.zip terminal_vm_persist/`

---

## Files to Include in ZIP

### ✅ Required (3 files)

#### 1. `module.prop`
```
Lines: 6
Permissions: 644
Content: Copy from "module.prop" artifact
```

#### 2. `service.sh`
```
Lines: 70
Permissions: 755 (executable)
Content: Copy from "service.sh" artifact
```

#### 3. `uninstall.sh`
```
Lines: 12
Permissions: 755 (executable)
Content: Copy from "uninstall.sh" artifact
```

---

### 📋 Optional but Recommended (3 files)

#### 4. `vm_control.sh`
```
Lines: 153
Permissions: 755 (executable)
Content: Copy from "vm_control.sh" artifact
Purpose: Manual VM control commands
```

#### 5. `system.prop`
```
Lines: 5
Permissions: 644
Content: Copy from "system.prop" artifact
Purpose: System property overrides
```

#### 6. `README.md`
```
Lines: 350+
Permissions: 644
Content: Copy from "README.md" artifact
Purpose: Full documentation
```

---

## Helper Scripts (Not included in ZIP)

### `auto_create_module.sh`
**Use for:** Automatic module creation  
**Content:** Copy from "auto_create_module.sh" artifact  
**How to use:**
```bash
chmod +x auto_create_module.sh
./auto_create_module.sh
# Creates terminal_vm_persist.zip automatically
```

### `build_module.sh`
**Use for:** Building ZIP from manual files  
**Content:** Copy from "build_module.sh" artifact  
**How to use:**
```bash
# First create all 6 module files
# Then run:
chmod +x build_module.sh
./build_module.sh
```

---

## Quick Start Guide

### For Linux/Mac Users:

```bash
# 1. Download auto_create_module.sh
# 2. Make it executable and run
chmod +x auto_create_module.sh
./auto_create_module.sh

# 3. Transfer ZIP to phone
adb push terminal_vm_persist.zip /sdcard/

# 4. Install via Magisk Manager
```

### For Windows Users:

```powershell
# Option A: Use WSL/Git Bash and run auto_create_module.sh

# Option B: Manual creation
# 1. Create folder: terminal_vm_persist
# 2. Create 6 text files with content from artifacts
# 3. Right-click folder → Send to → Compressed folder
# 4. Rename to terminal_vm_persist.zip
```

---

## File Structure in ZIP

The final ZIP must have this structure:

```
terminal_vm_persist.zip
├── module.prop          (6 lines)
├── service.sh           (70 lines, executable)
├── uninstall.sh         (12 lines, executable)
├── vm_control.sh        (153 lines, executable)
├── system.prop          (5 lines)
└── README.md            (350+ lines)
```

**IMPORTANT:** Files must be in ROOT of ZIP, not in a subfolder!

---

## Verification Checklist

Before installing, verify:

- [ ] ZIP contains `module.prop`, `service.sh`, `uninstall.sh`
- [ ] All `.sh` files are marked as executable (755)
- [ ] Files use Unix line endings (LF), not Windows (CRLF)
- [ ] Files are in root of ZIP, not nested in a folder
- [ ] ZIP size is approximately 15-20 KB
- [ ] Can extract and view all files without errors

Test extraction:
```bash
unzip -l terminal_vm_persist.zip
```

---

## What Each File Does

| File | Purpose | When It Runs |
|------|---------|--------------|
| module.prop | Module metadata | Read by Magisk |
| service.sh | Main persistence logic | Every boot |
| uninstall.sh | Cleanup | Module removal |
| vm_control.sh | Manual commands | User runs it |
| system.prop | System overrides | Boot time |
| README.md | Documentation | Reference |

---

## Installation Summary

1. **Create** `terminal_vm_persist.zip` (use auto script or manual)
2. **Transfer** to device: `adb push terminal_vm_persist.zip /sdcard/`
3. **Install** via Magisk Manager → Modules → Install from storage
4. **Reboot** device
5. **Verify:** `su -c /data/adb/modules/terminal_vm_persist/vm_control.sh status`

---

## Troubleshooting File Creation

### "Permission denied" when running scripts
```bash
chmod +x script_name.sh
```

### "Bad interpreter" error
- File has Windows line endings (CRLF)
- Convert to Unix: `dos2unix script_name.sh`
- Or use sed: `sed -i 's/\r$//' script_name.sh`

### ZIP structure is wrong
- Files must be in root of ZIP
- Don't ZIP the folder, ZIP the contents
- Correct: `cd terminal_vm_persist && zip -r ../module.zip .`
- Wrong: `zip -r module.zip terminal_vm_persist/`

### Module won't install
- Check module.prop format
- Verify all required fields present
- Ensure files are in root of ZIP
- Check Magisk version (need 20.4+)

---

## All Artifacts Reference

Copy content from these artifacts in the repo:

1. **module.prop** → "module.prop"
2. **service.sh** → "service.sh"  
3. **uninstall.sh** → "uninstall.sh"
4. **vm_control.sh** → "vm_control.sh"
5. **system.prop** → "system.prop"
6. **README.md** → "README.md"
7. **auto_create_module.sh** → "auto_create_module.sh"
8. **build_module.sh** → "build_module.sh"

---

## Final Note

**Easiest method:** Just run `auto_create_module.sh` and you're done! It creates everything automatically.
