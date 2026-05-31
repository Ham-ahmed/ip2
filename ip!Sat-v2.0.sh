#!/bin/sh

# ============================================================
# Script: IP2SAT Ultra Mod Installer (Fixed)
# ============================================================

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
#########################################
plugin="IP2SATUltraMod"
git_url="https://raw.githubusercontent.com/Ham-ahmed/ip2/refs/heads/main/iptosat"
plugin_path="/usr/lib/enigma2/python/Plugins/Extensions/IP2SAT"
targz_file="$plugin.tar.gz"
temp_dir="/tmp"

echo ""
echo -e "${CYAN}════════════════════════════════════════${NC}"
echo -e "${GREEN}     Installing $plugin ...${NC}"
echo -e "${CYAN}════════════════════════════════════════${NC}"
echo ""

# Get version
#########################################
echo -e "${YELLOW}➜ Checking version...${NC}"
version=$(wget "$git_url/version" -qO- 2>/dev/null | head -1)

if [ -z "$version" ]; then
    echo -e "${RED}✗ Failed to get version${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Version: $version${NC}"

# Remove old version if exists
#########################################
if [ -d "$plugin_path" ]; then
    echo -e "${YELLOW}➜ Removing old version...${NC}"
    rm -rf "$plugin_path" 2>/dev/null
    sleep 1
    echo -e "${GREEN}✓ Old version removed${NC}"
fi

# Download plugin
#########################################
echo -e "${YELLOW}➜ Downloading plugin...${NC}"
url="$git_url/$targz_file"
wget --no-check-certificate -q --show-progress "$url" -O "$temp_dir/$targz_file"

if [ ! -f "$temp_dir/$targz_file" ]; then
    echo -e "${RED}✗ Download failed - file not found${NC}"
    exit 1
fi

file_size=$(stat -c%s "$temp_dir/$targz_file" 2>/dev/null || stat -f%z "$temp_dir/$targz_file" 2>/dev/null)
if [ "$file_size" -lt 1000 ]; then
    echo -e "${RED}✗ Download failed - file too small ($file_size bytes)${NC}"
    rm -f "$temp_dir/$targz_file"
    exit 1
fi
echo -e "${GREEN}✓ Downloaded successfully (${file_size} bytes)${NC}"

# Extract plugin
#########################################
echo -e "${YELLOW}➜ Extracting plugin...${NC}"
if tar -xzf "$temp_dir/$targz_file" -C / 2>/dev/null; then
    echo -e "${GREEN}✓ Extraction completed${NC}"
else
    echo -e "${RED}✗ Extraction failed${NC}"
    rm -f "$temp_dir/$targz_file"
    exit 1
fi

# Clean up
#########################################
rm -f "$temp_dir/$targz_file"
rm -rf /CONTROL /control /postinst /preinst /prerm /postrm 2>/dev/null

# Verify installation
#########################################
echo -e "${YELLOW}➜ Verifying installation...${NC}"
sleep 1

if [ -d "$plugin_path" ]; then
    echo -e "${GREEN}✓ Plugin installed successfully!${NC}"
    echo ""
    echo -e "${CYAN}════════════════════════════════════════${NC}"
    echo -e "${GREEN}    $plugin-$version installed!${NC}"
    echo -e "${CYAN}════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}➜ Please restart Enigma2 GUI${NC}"
    echo -e "${YELLOW}   (Menu > Standby/Restart > Restart GUI)${NC}"
else
    echo -e "${RED}✗ Installation failed - plugin directory not found${NC}"
    exit 1
fi
```

## إذا استمرت مشكلة "Installation failed"، جرب هذا السكريبت التشخيصي:

```bash
#!/bin/sh

# Diagnostic Script - Test each step separately

git_url="https://raw.githubusercontent.com/Ham-ahmed/ip2/refs/heads/main/iptosat"
temp_dir="/tmp"
targz_file="IP2SATUltraMod.tar.gz"

echo "=== Diagnostic Test ==="
echo ""

# Test 1: Check internet and GitHub access
echo "1. Testing GitHub access..."
if wget --spider -q "$git_url/version"; then
    echo "   ✓ GitHub accessible"
else
    echo "   ✗ Cannot access GitHub"
    echo "   Check your internet connection"
    exit 1
fi

# Test 2: Get version
echo ""
echo "2. Getting version file..."
version=$(wget "$git_url/version" -qO- 2>/dev/null | head -1)
if [ -n "$version" ]; then
    echo "   ✓ Version: $version"
else
    echo "   ✗ Failed to get version"
    exit 1
fi

# Test 3: Download tar.gz
echo ""
echo "3. Downloading plugin file..."
url="$git_url/$targz_file"
wget --no-check-certificate -q "$url" -O "$temp_dir/$targz_file"
if [ -f "$temp_dir/$targz_file" ]; then
    size=$(ls -la "$temp_dir/$targz_file" | awk '{print $5}')
    echo "   ✓ Downloaded: $size bytes"
else
    echo "   ✗ Download failed"
    exit 1
fi

# Test 4: Test tar.gz integrity
echo ""
echo "4. Testing archive integrity..."
if gunzip -t "$temp_dir/$targz_file" 2>/dev/null; then
    echo "   ✓ Archive is valid"
else
    echo "   ✗ Archive is corrupted"
    exit 1
fi

# Test 5: List contents
echo ""
echo "5. Archive contents:"
tar -tzf "$temp_dir/$targz_file" 2>/dev/null | head -10
echo "   ..."

# Test 6: Try extraction to temp directory
echo ""
echo "6. Testing extraction..."
test_dir="/tmp/test_extract"
mkdir -p "$test_dir"
if tar -xzf "$temp_dir/$targz_file" -C "$test_dir" 2>/dev/null; then
    echo "   ✓ Extraction test successful"
    echo "   Contents extracted to: $test_dir"
    ls -la "$test_dir/" 2>/dev/null
else
    echo "   ✗ Extraction test failed"
    exit 1
fi

echo ""
echo "=== All tests passed! ==="
echo "The plugin file is working correctly."
echo "If installation still fails, you may have:"
echo "- Insufficient permissions (try: chmod 755 /usr/lib/enigma2/python/Plugins/Extensions)"
echo "- Not enough free space (check: df -h)"
echo "- Write-protected filesystem"