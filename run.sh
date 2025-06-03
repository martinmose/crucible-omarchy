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

# Install paru AUR helper if not present
if ! command -v paru &>/dev/null; then
    echo "Installing paru AUR helper..."
    sudo pacman -S --needed git base-devel --noconfirm
    if [[ ! -d "paru" ]]; then
        echo "Cloning paru repository..."
    else
        echo "paru directory already exists, removing it..."
        rm -rf paru
    fi

    git clone https://aur.archlinux.org/paru.git

    cd paru
    echo "Building paru..."
    makepkg -si --noconfirm
    cd ..
    rm -rf paru
else
    echo "paru is already installed"
fi

# Install packages by category
echo "Installing system utilities..."
install_packages "${SYSTEM_UTILS[@]}"

echo "Installing development tools..."
install_packages "${DEV_TOOLS[@]}"

echo "Installing system maintenance tools..."
install_packages "${MAINTENANCE[@]}"

echo "Installing desktop environment..."
install_packages "${DESKTOP[@]}"

echo "Installing applications..."
install_packages "${APPLICATIONS[@]}"

echo "Installing media packages..."
install_packages "${MEDIA[@]}"

echo "Installing fonts..."
install_packages "${FONTS[@]}"

# Enable services
echo "Configuring services..."
for service in "${SERVICES[@]}"; do
    if ! systemctl is-enabled "$service" &>/dev/null; then
        echo "Enabling $service..."
        sudo systemctl enable "$service"
    else
        echo "$service is already enabled"
    fi
done

# Setup complete

echo "Setup complete! You may want to reboot your system."
