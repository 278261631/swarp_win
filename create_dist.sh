#!/bin/bash
# Script to create a distribution package for SWarp on Windows

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== SWarp Distribution Package Creator ===${NC}"
echo ""

# Check if swarp.exe exists
if [ ! -f "build/src/swarp.exe" ]; then
    echo -e "${RED}Error: swarp.exe not found in build/src${NC}"
    echo "Please compile the project first."
    exit 1
fi

# Create dist directory
DIST_DIR="dist"
echo -e "${GREEN}Creating distribution directory: $DIST_DIR${NC}"
rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

# Copy executable
echo -e "${GREEN}Copying swarp.exe...${NC}"
cp build/src/swarp.exe "$DIST_DIR/"

# Copy DLL files
echo -e "${GREEN}Copying DLL files...${NC}"
if [ -f "build/src/msys-2.0.dll" ]; then
    cp build/src/msys-2.0.dll "$DIST_DIR/"
    echo -e "  ${GREEN}✓${NC} msys-2.0.dll"
else
    echo -e "  ${RED}✗${NC} msys-2.0.dll not found"
fi

if [ -f "build/src/msys-gcc_s-seh-1.dll" ]; then
    cp build/src/msys-gcc_s-seh-1.dll "$DIST_DIR/"
    echo -e "  ${GREEN}✓${NC} msys-gcc_s-seh-1.dll"
else
    echo -e "  ${RED}✗${NC} msys-gcc_s-seh-1.dll not found"
fi

if [ -f "build/src/libwinpthread-1.dll" ]; then
    cp build/src/libwinpthread-1.dll "$DIST_DIR/"
    echo -e "  ${GREEN}✓${NC} libwinpthread-1.dll"
else
    echo -e "  ${YELLOW}⚠${NC} libwinpthread-1.dll not found (optional)"
fi

# Copy documentation
echo -e "${GREEN}Copying documentation...${NC}"
if [ -f "README_WINDOWS.md" ]; then
    cp README_WINDOWS.md "$DIST_DIR/README.md"
    echo -e "  ${GREEN}✓${NC} README.md"
fi

if [ -f "BUILD_WINDOWS.md" ]; then
    cp BUILD_WINDOWS.md "$DIST_DIR/"
    echo -e "  ${GREEN}✓${NC} BUILD_WINDOWS.md"
fi

# Create a simple usage guide
cat > "$DIST_DIR/USAGE.txt" << 'EOF'
SWarp for Windows - Quick Start Guide
======================================

1. Basic Usage
--------------
Open Command Prompt (CMD) or PowerShell and navigate to this directory.

View version:
  swarp.exe -v

Generate default configuration:
  swarp.exe -d > default.swarp

Process FITS files:
  swarp.exe image1.fits image2.fits -c config.swarp

2. Important Files
------------------
- swarp.exe              : Main executable
- msys-2.0.dll           : Required runtime library
- msys-gcc_s-seh-1.dll   : Required GCC library
- libwinpthread-1.dll    : Threading support library
- README.md              : Detailed documentation
- BUILD_WINDOWS.md       : Build instructions

3. Requirements
---------------
- Windows 7 or higher (64-bit)
- All DLL files must be in the same directory as swarp.exe

4. Troubleshooting
------------------
If you get "DLL not found" errors:
- Make sure all DLL files are in the same directory as swarp.exe
- Do not move swarp.exe without the DLL files

For more help, see README.md

5. License
----------
SWarp is free software under GNU General Public License v3.0

For more information, visit:
https://astromatic.net/software/swarp
EOF

echo -e "  ${GREEN}✓${NC} USAGE.txt"

# List contents
echo ""
echo -e "${BLUE}Distribution package contents:${NC}"
echo "-----------------------------------"
ls -lh "$DIST_DIR" | tail -n +2 | awk '{printf "  %-30s %8s\n", $9, $5}'

# Calculate total size
TOTAL_SIZE=$(du -sh "$DIST_DIR" | cut -f1)
echo ""
echo -e "${GREEN}Total package size: $TOTAL_SIZE${NC}"

# Test the executable
echo ""
echo -e "${BLUE}Testing executable...${NC}"
if "$DIST_DIR/swarp.exe" -v > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Executable test passed!${NC}"
else
    echo -e "${RED}✗ Executable test failed!${NC}"
    exit 1
fi

# Create a zip archive if zip is available
if command -v zip &> /dev/null; then
    echo ""
    echo -e "${BLUE}Creating ZIP archive...${NC}"
    ZIP_NAME="swarp-windows-$(date +%Y%m%d).zip"
    cd "$DIST_DIR"
    zip -q -r "../$ZIP_NAME" .
    cd ..
    if [ -f "$ZIP_NAME" ]; then
        ZIP_SIZE=$(du -sh "$ZIP_NAME" | cut -f1)
        echo -e "${GREEN}✓ Created: $ZIP_NAME ($ZIP_SIZE)${NC}"
    fi
fi

echo ""
echo -e "${GREEN}=== Distribution package created successfully! ===${NC}"
echo ""
echo -e "${YELLOW}Distribution directory: $DIST_DIR/${NC}"
echo ""
echo -e "You can now:"
echo -e "  1. Test: ${YELLOW}cd $DIST_DIR && ./swarp.exe -v${NC}"
echo -e "  2. Copy the entire ${YELLOW}$DIST_DIR/${NC} folder to another location"
echo -e "  3. Share the ZIP archive (if created)"
echo ""

