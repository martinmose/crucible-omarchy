#!/bin/bash

print_logo() {
    cat <<"EOF"
     ______                _ __    __     
    / ____/______  _______(_) /_  / /__   
   / /   / ___/ / / / ___/ / __ \/ / _ \  
  / /___/ /  / /_/ / /__/ / /_/ / /  __/  Keyd Setup Tool
  \____/_/   \__,_/\___/_/_.___/_/\___/   by: martinmose 

EOF
}

clear
print_logo

# Exit on any error
set -e

echo "Setting up keyd keyboard remapping..."
echo ""

# Check if keyd is installed
if ! command -v keyd &> /dev/null; then
    echo "Error: keyd is not installed."
    echo "Please install keyd first: sudo pacman -S keyd"
    exit 1
fi

# Create keyd directory if it doesn't exist
sudo mkdir -p /etc/keyd

# Copy configuration
echo "Installing keyd configuration..."
sudo cp "$(dirname "$0")/../default.conf" /etc/keyd/default.conf

# Enable and start service
echo "Enabling and starting keyd service..."
sudo systemctl enable --now keyd

echo ""
echo "Keyd setup complete!"
echo "Danish character shortcuts are now active."
echo ""