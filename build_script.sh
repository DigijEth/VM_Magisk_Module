#!/bin/bash
# Build Script for Terminal VM Persistence Magisk Module
# Run this script to create the installable ZIP file

set -e

MODULE_NAME="terminal_vm_persist"
BUILD_DIR="$MODULE_NAME"
OUTPUT_ZIP="${MODULE_NAME}.zip"

echo "========================================="
echo "Terminal VM Persistence Module Builder"
echo "========================================="
echo ""

# Check if running in correct directory
if [ ! -f "module.prop" ]; then
    echo "Error: module.prop not found!"
    echo "Please run this script from the module directory containing all files."
    exit 1
fi

# Verify required files exist
echo "[1/5] Verifying required files..."
REQUIRED_FILES=("module.prop" "service.sh" "uninstall.sh")
for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "Error: Required file '$file' not found!"
        exit 1
    fi
    echo "  ✓ $file"
done

# Check optional files
OPTIONAL_FILES=("vm_control.sh" "system.prop" "README.md")
for file in "${OPTIONAL_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✓ $file (optional)"
    else
        echo "  ⚠ $file (optional - not found)"
    fi
done

# Set correct permissions
echo ""
echo "[2/5] Setting file permissions..."
chmod 644 module.prop 2>/dev/null || true
chmod 755 service.sh
chmod 755 uninstall.sh
[ -f "vm_control.sh" ] && chmod 755 vm_control.sh
[ -f "system.prop" ] && chmod 644 system.prop 2>/dev/null || true
[ -f "README.md" ] && chmod 644 README.md 2>/dev/null || true
echo "  ✓ Permissions set"

# Check for CRLF line endings (Windows)
echo ""
echo "[3/5] Checking line endings..."
for file in *.sh; do
    if [ -f "$file" ]; then
        if file "$file" | grep -q CRLF; then
            echo "  ⚠ Warning: $file has Windows (CRLF) line endings"
            echo "    Converting to Unix (LF) line endings..."
            if command -v dos2unix &> /dev/null; then
                dos2unix "$file"
                echo "    ✓ Converted using dos2unix"
            elif command -v sed &> /dev/null; then
                sed -i 's/\r$//' "$file"
                echo "    ✓ Converted using sed"
            else
                echo "    ⚠ Please install dos2unix or manually convert line endings"
            fi
        else
            echo "  ✓ $file has correct line endings"
        fi
    fi
done

# Validate module.prop
echo ""
echo "[4/5] Validating module.prop..."
if grep -q "^id=" module.prop && \
   grep -q "^name=" module.prop && \
   grep -q "^version=" module.prop && \
   grep -q "^versionCode=" module.prop; then
    echo "  ✓ module.prop format is valid"
    echo ""
    echo "  Module Info:"
    grep "^name=" module.prop
    grep "^version=" module.prop
    grep "^author=" module.prop
else
    echo "  ✗ Error: module.prop is missing required fields"
    exit 1
fi

# Create ZIP file
echo ""
echo "[5/5] Creating ZIP file..."
if [ -f "$OUTPUT_ZIP" ]; then
    echo "  ⚠ Removing existing $OUTPUT_ZIP"
    rm "$OUTPUT_ZIP"
fi

# Determine which files to include
FILES_TO_ZIP="module.prop service.sh uninstall.sh"
[ -f "vm_control.sh" ] && FILES_TO_ZIP="$FILES_TO_ZIP vm_control.sh"
[ -f "system.prop" ] && FILES_TO_ZIP="$FILES_TO_ZIP system.prop"
[ -f "README.md" ] && FILES_TO_ZIP="$FILES_TO_ZIP README.md"

# Create the ZIP
zip -r9 "$OUTPUT_ZIP" $FILES_TO_ZIP > /dev/null

if [ -f "$OUTPUT_ZIP" ]; then
    echo "  ✓ ZIP file created successfully!"
    echo ""
    echo "========================================="
    echo "BUILD COMPLETE!"
    echo "========================================="
    echo ""
    echo "Output: $OUTPUT_ZIP"
    echo "Size: $(du -h "$OUTPUT_ZIP" | cut -f1)"
    echo ""
    echo "ZIP Contents:"
    unzip -l "$OUTPUT_ZIP"
    echo ""
    echo "Next steps:"
    echo "1. Transfer $OUTPUT_ZIP to your device"
    echo "2. Open Magisk Manager"
    echo "3. Install from storage"
    echo "4. Reboot device"
    echo ""
else
    echo "  ✗ Error: Failed to create ZIP file"
    exit 1
fi