# Files Checklist for Terminal VM Persistence Module

## Required Files (Must Have)

### 1. `module.prop`
**Type:** Text file  
**Permissions:** 644  
**Content:** Module metadata (5 lines)
```
id=terminal_vm_persist
name=Android 16 Terminal VM Persistence
version=1.0
versionCode=1
author=AVF Enthusiast
description=Keeps Android 16 Linux Terminal VM running persistently
```

### 2. `service.sh`
**Type:** Shell script  
**Permissions:** 755 (executable)  
**Content:** ~70 lines - Boot service that monitors and protects VM  
**Purpose:** Runs automatically on boot to keep Terminal VM alive

### 3. `uninstall.sh`
**Type:** Shell script  
**Permissions:** 755 (executable)  
**Content:** ~10 lines - Cleanup script  
**Purpose:** Runs when module is removed to kill services

---

## Optional Files (Recommended)

### 4. `vm_control.sh`
**Type:** Shell script  
**Permissions:** 755 (executable)  
**Content:** ~150 lines - Manual control script  
**Purpose:** Provides commands for checking status, protecting VMs, viewing logs

### 5. `system.prop`
**Type:** Properties file  
**Permissions:** 644  
**Content:** ~15 lines - System property overrides (mostly comments)  
**Purpose:** Optional system-level configurations

### 6. `README.md`
**Type:** Markdown documentation  
**Permissions:** 644  
**Content:** Full documentation  
**Purpose:** User guide and reference

---

## Build Files (For Development)

### 7. `build_module.sh`
**Type:** Shell script  
**Permissions:** 755 (executable)  
**Content:** ~110 lines - Automated build script  
**Purpose:** Creates the ZIP file with proper structure

### 8. `INSTALLATION_GUIDE.txt`
**Type:** Text documentation  
**Permissions:** 644  
**Content:** Installation instructions  
**Purpose:** Step-by-step setup guide

---

## File Creation Checklist

- [ ] Create directory: `terminal_vm_persist/`
- [ ] Copy `module.prop` content → save as `module.prop`
- [ ] Copy `service.sh` content → save as `service.sh`
- [ ] Copy `uninstall.sh` content → save as `uninstall.sh`
- [ ] Copy `vm_control.sh` content → save as `vm_control.sh`
- [ ] Copy `system.prop` content → save as `system.prop`
- [ ] Copy `README.md` content → save as `README.md`
- [ ] Set permissions: `chmod 755 *.sh`
- [ ] Verify line endings: Unix (LF) not Windows (CRLF)
- [ ] Create ZIP: `zip -r terminal_vm_persist.zip terminal_vm_persist/`
- [ ] Test ZIP: `unzip -l terminal_vm_persist.zip`

---

## Quick Create Commands

### Linux/Mac:
```bash
# Create all files at once
cat > module.prop << 'EOF'
[paste content here]
EOF

cat > service.sh << 'EOF'
[paste content here]
EOF

# ... repeat for other files

# Set permissions
chmod 755 *.sh

# Create ZIP
zip -r terminal_vm_persist.zip .
```

### Windows PowerShell:
```powershell
# Create files using notepad
notepad module.prop
notepad service.sh
notepad uninstall.sh

# Create ZIP
Compress-Archive -Path * -DestinationPath terminal_vm_persist.zip
```

---

## Final ZIP Structure

The final ZIP must look like this:

```
terminal_vm_persist.zip
├── module.prop          [REQUIRED]
├── service.sh           [REQUIRED]
├── uninstall.sh         [REQUIRED]
├── vm_control.sh        [optional]
├── system.prop          [optional]
└── README.md            [optional]
```

**Important:** Files must be in the root of the ZIP, NOT in a subdirectory!

❌ **Wrong:**
```
terminal_vm_persist.zip
└── terminal_vm_persist/
    ├── module.prop
    └── ...
```

✅ **Correct:**
```
terminal_vm_persist.zip
├── module.prop
└── ...
```

---

## Where to Get File Contents

All file contents are in the artifacts from this conversation:

| File | Artifact Name | Lines |
|------|---------------|-------|
| module.prop | "module.prop" | 6 |
| service.sh | "service.sh" | 70 |
| uninstall.sh | "uninstall.sh" | 12 |
| vm_control.sh | "vm_control.sh" | 153 |
| system.prop | "system.prop" | 15 |
| README.md | "README.md" | 350 |
| build_module.sh | "build_module.sh" | 112 |

Simply copy the content from each artifact and paste into a new file with the corresponding name.

---

## Verification Before Installing

Before installing the module, verify:

1. ✓ All required files present
2. ✓ Shell scripts are executable (755)
3. ✓ Files use Unix line endings (LF)
4. ✓ ZIP structure is correct (files in root)
5. ✓ module.prop has valid format
6. ✓ No syntax errors in shell scripts

Run build_module.sh to automate verification!