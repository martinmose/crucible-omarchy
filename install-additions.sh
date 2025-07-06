#!/bin/bash

# Print the logo
print_logo() {
  cat <<"EOF"
    ______                _ __    __     
   / ____/______  _______(_) /_  / /__   
  / /   / ___/ / / / ___/ / __ \/ / _ \  
 / /___/ /  / /_/ / /__/ / /_/ / /  __/  Arch Linux System Crafting Tool
 \____/_/   \__,_/\___/_/_.___/_/\___/   by: martinmose 

EOF
}

# No command line arguments needed

# Clear screen and show logo
clear
print_logo

# Exit on any error
set -e

# Source utility functions
source utils.sh

# Source the package list
if [ ! -f "packages.conf" ]; then
  echo "Error: packages.conf not found!"
  exit 1
fi

source packages.conf

echo "Starting system setup..."

# Update the system first
echo "Updating system..."
sudo pacman -Syu --noconfirm

# Install packages by category
echo "Installing system utilities..."
install_packages "${SYSTEM_UTILS[@]}"

echo "Installing ai tools..."
install_packages "${AI_TOOLS[@]}"

echo "Installing development tools..."
install_packages "${DEV_TOOLS[@]}"

echo "Installing applications..."
install_packages "${APPLICATIONS[@]}"

echo "Installing fonts..."
install_packages "${FONTS[@]}"

# Initialize gnome-keyring if it was installed
# This creates a default keyring with no password (auto-unlock on login)
# If you want password protection, you can manually reinitialize later with:
# secret-tool store --label="test" test test (and set a password in the dialog)
# secret-tool clear test test
if is_installed "gnome-keyring"; then
    echo "Initializing gnome-keyring..."
    if command -v secret-tool &>/dev/null; then
        # Create keyring with no password (auto-unlock)
        echo "test" | secret-tool store --label="test" test test 2>/dev/null || true
        secret-tool clear test test 2>/dev/null || true
        echo "Keyring initialized (auto-unlock on login)"
    fi
fi

# Setup complete

echo "Setup complete! You may want to reboot your system."
