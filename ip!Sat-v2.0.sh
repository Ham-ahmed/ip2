#!/bin/sh

#=====================================================================
# IP2SAT Ultra Mod Installer
# Script corrected and fully functional
#=====================================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Variables
plugin="IP2SATUltraMod"
git_url="https://raw.githubusercontent.com/Ham-ahmed/ip2/refs/heads/main/iptosat"
plugin_path="/usr/lib/enigma2/python/Plugins/Extensions/IP2SAT"
targz_file="$plugin.tar.gz"
temp_dir="/tmp"

echo ""
echo "$BLUE========================================$NC"
echo "$GREEN     Installing $plugin $NC"
echo "$BLUE========================================$NC"
echo ""

# Get version
echo "$YELLOUW> Getting version...$NC"
version=$(wget -qO- $git_url/version 2>/dev/null | head -1)

if [ -z "$version" ]; then
    version="latest"
    echo "$RED> Could not get version, using: $version$NC"
else
    echo "$GREEN> Version: $version$NC"
fi

# Remove old version
if [ -d $plugin_path ]; then
    echo "$YELLOW> Removing old version...$NC"
    rm -rf $plugin_path 2>/dev/null
    echo "$GREEN> Old version removed$NC"
fi

# Download
echo "$YELLOW> Downloading plugin...$NC"
url="$git_url/$targz_file"
wget -q --show-progress $url -O $temp_dir/$targz_file 2>/dev/null

if [ ! -f $temp_dir/$targz_file ]; then
    echo "$RED> Download failed!$NC"
    exit 1
fi

echo "$GREEN> Download completed$NC"

# Extract
echo "$YELLOW> Extracting plugin...$NC"
tar -xzf $temp_dir/$targz_file -C / 2>/dev/null

if [ $? -eq 0 ]; then
    echo "$GREEN> Extraction completed$NC"
else
    echo "$RED> Extraction failed!$NC"
    rm -f $temp_dir/$targz_file
    exit 1
fi

# Clean
rm -f $temp_dir/$targz_file
rm -rf /CONTROL /control /postinst /preinst /prerm /postrm 2>/dev/null

# Verify
if [ -d $plugin_path ]; then
    echo ""
    echo "$BLUE========================================$NC"
    echo "$GREEN     Installation Successful! $NC"
    echo "$BLUE========================================$NC"
    echo ""
    echo "$YELLOW> Please restart Enigma2 GUI$NC"
    echo "$YELLOW> Menu > Standby/Restart > Restart GUI$NC"
else
    echo "$RED> Installation failed!$NC"
    exit 1
fi