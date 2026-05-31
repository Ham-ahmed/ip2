#!/bin/sh

# ============================================================
# Script: IP2SAT Ultra Mod Installer
# Purpose: Install/Update IP2SAT plugin for Enigma2
# ============================================================

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Configuration
#########################################
plugin="IP2SATUltraMod"
git_url="https://raw.githubusercontent.com/Ham-ahmed/ip2/refs/heads/main/iptosat"
plugin_path="/usr/lib/enigma2/python/Plugins/Extensions/IP2SAT"
package="enigma2-plugin-extensions-$plugin"
targz_file="$plugin.tar.gz"
temp_dir="/tmp"
backup_dir="/tmp/ip2sat_backup"

# Determine package manager
#########################################
if command -v dpkg &> /dev/null; then
    package_manager="apt"
    status_file="/var/lib/dpkg/status"
    uninstall_command="apt-get purge --auto-remove -y"
else
    package_manager="opkg"
    status_file="/var/lib/opkg/status"
    uninstall_command="opkg remove --force-depends"
fi

# Function: Print colored messages
#########################################
print_message() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

# Function: Check internet connectivity
#########################################
check_internet() {
    print_info "Checking internet connection..."
    if wget -q --spider http://google.com 2>/dev/null; then
        print_message "Internet connection OK"
        return 0
    else
        print_error "No internet connection"
        return 1
    fi
}

# Function: Get version from remote
#########################################
get_remote_version() {
    local remote_version=$(wget "$git_url/version" -qO- 2>/dev/null | head -1 | tr -d '\n\r')
    if [ -z "$remote_version" ]; then
        print_error "Failed to get version from remote repository"
        return 1
    fi
    echo "$remote_version"
    return 0
}

# Function: Create backup of existing plugin
#########################################
create_backup() {
    if [ -d "$plugin_path" ]; then
        print_info "Creating backup of existing plugin..."
        rm -rf "$backup_dir" 2>/dev/null
        cp -r "$plugin_path" "$backup_dir" 2>/dev/null
        if [ -d "$backup_dir" ]; then
            print_message "Backup created successfully"
            return 0
        else
            print_warning "Failed to create backup"
            return 1
        fi
    fi
    return 0
}

# Function: Restore backup
#########################################
restore_backup() {
    if [ -d "$backup_dir" ]; then
        print_warning "Restoring from backup..."
        rm -rf "$plugin_path" 2>/dev/null
        cp -r "$backup_dir" "$plugin_path" 2>/dev/null
        print_message "Backup restored"
    fi
}

# Function: Remove old version
#########################################
remove_old_version() {
    if [ -d "$plugin_path" ]; then
        print_info "Removing old plugin version..."
        sleep 1
        
        # Remove plugin directory
        rm -rf "$plugin_path" 2>/dev/null
        
        # Remove package from package manager if exists
        if grep -q "$package" "$status_file" 2>/dev/null; then
            print_info "Removing existing package: $package"
            $uninstall_command "$package" > /dev/null 2>&1
        fi
        
        # Clear Python cache
        find /usr/lib/enigma2/python/Plugins/Extensions -name "*.pyc" -delete 2>/dev/null
        find /usr/lib/enigma2/python/Plugins/Extensions -name "*.pyo" -delete 2>/dev/null
        
        print_message "Old version removed successfully"
        sleep 1
    else
        print_info "No previous installation found"
    fi
}

# Function: Download and install plugin
#########################################
download_and_install() {
    local version=$1
    local url="$git_url/$targz_file"
    
    print_info "Downloading $plugin version $version..."
    sleep 1
    
    # Download with progress and timeout
    if wget --timeout=30 --tries=3 --show-progress -qO "$temp_dir/$targz_file" --no-check-certificate "$url"; then
        print_message "Download completed successfully"
    else
        print_error "Download failed"
        return 1
    fi
    
    # Verify downloaded file is not empty
    if [ ! -s "$temp_dir/$targz_file" ]; then
        print_error "Downloaded file is empty"
        return 1
    fi
    
    # Verify tar.gz integrity
    print_info "Verifying archive integrity..."
    if gunzip -t "$temp_dir/$targz_file" 2>/dev/null; then
        print_message "Archive integrity verified"
    else
        print_error "Archive is corrupted"
        rm -f "$temp_dir/$targz_file"
        return 1
    fi
    
    # Extract archive
    print_info "Extracting archive..."
    if tar -xzf "$temp_dir/$targz_file" -C / 2>/dev/null; then
        print_message "Extraction completed successfully"
    else
        print_error "Extraction failed"
        rm -f "$temp_dir/$targz_file"
        return 1
    fi
    
    # Clean up temp file
    rm -f "$temp_dir/$targz_file"
    
    return 0
}

# Function: Verify installation
#########################################
verify_installation() {
    print_info "Verifying installation..."
    
    if [ -d "$plugin_path" ]; then
        # Check for main plugin file
        if [ -f "$plugin_path/plugin.py" ] || [ -f "$plugin_path/__init__.py" ]; then
            print_message "Plugin files verified successfully"
            return 0
        else
            print_error "Plugin files missing after installation"
            return 1
        fi
    else
        print_error "Plugin directory not found after installation"
        return 1
    fi
}

# Function: Cleanup temporary files
#########################################
cleanup() {
    # Remove temporary files
    rm -f /tmp/*.ipk /tmp/*.tar.gz /tmp/*.deb 2>/dev/null
    rm -f /CONTROL /control /postinst /preinst /prerm /postrm 2>/dev/null
    rm -rf /tmp/ip2sat_* 2>/dev/null
    
    # Remove backup if installation succeeded
    if [ -f "/tmp/install_success" ]; then
        rm -rf "$backup_dir" 2>/dev/null
        rm -f "/tmp/install_success"
    fi
    
    # Clear Python cache
    find /usr/lib/enigma2/python/Plugins/Extensions -name "*.pyc" -delete 2>/dev/null
    find /usr/lib/enigma2/python/Plugins/Extensions -name "*.pyo" -delete 2>/dev/null
}

# Function: Restart Enigma2 GUI
#########################################
restart_gui() {
    print_info "Do you want to restart Enigma2 GUI? (y/n)"
    echo -e -n "${CYAN}Restart? [y/N]: ${NC}"
    read -r answer
    
    case "$answer" in
        y|Y|yes|YES)
            print_info "Restarting Enigma2 GUI..."
            sleep 2
            killall -9 enigma2 2>/dev/null
            ;;
        *)
            print_warning "Please restart Enigma2 manually to use the plugin"
            ;;
    esac
}

# ============================================================
# Main Execution
# ============================================================
main() {
    clear 2>/dev/null
    echo ""
    echo -e "${MAGENTA}╔════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║     $plugin Installer v1.0      ║${NC}"
    echo -e "${MAGENTA}╚════════════════════════════════════════╝${NC}"
    echo ""
    
    # Check internet
    if ! check_internet; then
        exit 1
    fi
    
    # Get remote version
    remote_version=$(get_remote_version)
    if [ -z "$remote_version" ]; then
        exit 1
    fi
    print_info "Remote version: $remote_version"
    
    # Create backup
    create_backup
    
    # Remove old version
    remove_old_version
    
    # Download and install
    if download_and_install "$remote_version"; then
        # Verify installation
        if verify_installation; then
            echo ""
            echo -e "${GREEN}════════════════════════════════════════${NC}"
            echo -e "${GREEN}✓ $plugin-$remote_version installed successfully!${NC}"
            echo -e "${GREEN}════════════════════════════════════════${NC}"
            touch /tmp/install_success
        else
            echo ""
            echo -e "${RED}════════════════════════════════════════${NC}"
            echo -e "${RED}✗ Installation verification failed!${NC}"
            echo -e "${RED}════════════════════════════════════════${NC}"
            restore_backup
            exit 1
        fi
    else
        echo ""
        echo -e "${RED}════════════════════════════════════════${NC}"
        echo -e "${RED}✗ Installation failed!${NC}"
        echo -e "${RED}════════════════════════════════════════${NC}"
        restore_backup
        exit 1
    fi
    
    # Cleanup
    cleanup
    
    # Print success message
    echo ""
    print_message "Plugin installed to: $plugin_path"
    echo ""
    
    # Ask for GUI restart
    restart_gui
}

# Run main function
main "$@"