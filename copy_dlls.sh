#!/bin/bash
# Script to copy necessary DLL files for SWarp on Windows/MSYS2

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== SWarp DLL Copy Script ===${NC}"
echo ""

# Determine the build directory
BUILD_DIR="build/src"
if [ ! -d "$BUILD_DIR" ]; then
    echo -e "${RED}Error: Build directory not found: $BUILD_DIR${NC}"
    echo "Please run this script from the project root directory."
    exit 1
fi

# Check if swarp.exe exists
if [ ! -f "$BUILD_DIR/swarp.exe" ]; then
    echo -e "${RED}Error: swarp.exe not found in $BUILD_DIR${NC}"
    echo "Please compile the project first."
    exit 1
fi

echo -e "${GREEN}Found swarp.exe in $BUILD_DIR${NC}"
echo ""

# List of required DLLs
REQUIRED_DLLS=(
    "msys-2.0.dll"
    "msys-gcc_s-seh-1.dll"
)

# Optional DLLs (for threading, etc.)
OPTIONAL_DLLS=(
    "msys-pthread-1.dll"
    "libwinpthread-1.dll"
)

# Search paths for DLLs
SEARCH_PATHS=(
    "/usr/bin"
    "/mingw64/bin"
    "C:/msys64/usr/bin"
    "C:/msys64/mingw64/bin"
)

# Function to find and copy a DLL
copy_dll() {
    local dll_name=$1
    local is_required=$2
    
    for search_path in "${SEARCH_PATHS[@]}"; do
        if [ -f "$search_path/$dll_name" ]; then
            echo -e "${GREEN}✓${NC} Found $dll_name at $search_path"
            cp "$search_path/$dll_name" "$BUILD_DIR/"
            if [ $? -eq 0 ]; then
                echo -e "  ${GREEN}Copied to $BUILD_DIR/${NC}"
                return 0
            else
                echo -e "  ${RED}Failed to copy${NC}"
                return 1
            fi
        fi
    done
    
    if [ "$is_required" = "true" ]; then
        echo -e "${RED}✗${NC} Could not find required DLL: $dll_name"
        return 1
    else
        echo -e "${YELLOW}⚠${NC} Optional DLL not found: $dll_name (skipping)"
        return 0
    fi
}

# Copy required DLLs
echo -e "${GREEN}Copying required DLLs...${NC}"
FAILED=0
for dll in "${REQUIRED_DLLS[@]}"; do
    copy_dll "$dll" "true"
    if [ $? -ne 0 ]; then
        FAILED=1
    fi
done

echo ""

# Copy optional DLLs
echo -e "${GREEN}Copying optional DLLs...${NC}"
for dll in "${OPTIONAL_DLLS[@]}"; do
    copy_dll "$dll" "false"
done

echo ""

# List all DLLs in the build directory
echo -e "${GREEN}DLL files in $BUILD_DIR:${NC}"
echo "-----------------------------------"
ls -lh "$BUILD_DIR"/*.dll 2>/dev/null | awk '{print $9, "(" $5 ")"}'

if [ $? -ne 0 ]; then
    echo -e "${YELLOW}No DLL files found${NC}"
fi

echo ""

# Final status
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All required DLLs copied successfully!${NC}"
    echo ""
    echo -e "${GREEN}You can now run swarp.exe from Windows CMD:${NC}"
    echo -e "  ${YELLOW}$BUILD_DIR\\swarp.exe -v${NC}"
    exit 0
else
    echo -e "${RED}✗ Some required DLLs could not be copied.${NC}"
    echo "Please check the error messages above."
    exit 1
fi

