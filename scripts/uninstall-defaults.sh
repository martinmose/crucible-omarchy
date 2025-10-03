#!/bin/bash

print_logo() {
    cat <<"EOF"
    ______                _ __    __     
   / ____/______  _______(_) /_  / /__   
  / /   / ___/ / / / ___/ / __ \/ / _ \  
 / /___/ /  / /_/ / /__/ / /_/ / /  __/  Omarchy Cleanup Tool
 \____/_/   \__,_/\___/_/_.___/_/\___/   by: martinmose 

EOF
}

clear
print_logo

# Exit on any error
set -e

# Ensure script is not run as root
if [ "$EUID" -eq 0 ]; then
    echo "Error: This script should not be run as root or with sudo."
    echo "Please run it as a regular user: ./scripts/uninstall-defaults.sh"
    exit 1
fi

source "$(dirname "$0")/utils.sh"

echo "Removing unwanted default Omarchy packages..."

# Load configuration
source "$(dirname "$0")/../uninstall-packages.conf"

# Use PACKAGES from config file
PACKAGES_TO_REMOVE=("${PACKAGES[@]}")

# Function to remove packages
remove_packages() {
    local packages=("$@")
    local to_remove=()

    for pkg in "${packages[@]}"; do
        # Special handling for rust package - check if it's explicitly installed, not just provided
        if [ "$pkg" = "rust" ]; then
            if pacman -Qq rust 2>/dev/null | grep -q "^rust$"; then
                to_remove+=("$pkg")
            fi
        elif is_installed "$pkg"; then
            to_remove+=("$pkg")
        fi
    done

    if [ ${#to_remove[@]} -ne 0 ]; then
        echo "Removing: ${to_remove[*]}"
        yay -Rns --noconfirm "${to_remove[@]}"
    else
        echo "No packages to remove (none are installed)"
    fi
}

# Remove packages if any are defined
if [ ${#PACKAGES_TO_REMOVE[@]} -ne 0 ]; then
    remove_packages "${PACKAGES_TO_REMOVE[@]}"
else
    echo "No packages configured for removal."
    echo "Edit this script and uncomment packages you want to remove."
fi

# Remove web apps using web2app-remove
echo "Removing Omarchy web apps..."
for app in "${WEBAPPS[@]}"; do
    # Remove .desktop extension for web2app-remove command
    app_name="${app%.desktop}"
    desktop_file="$HOME/.local/share/applications/${app_name}.desktop"
    
    if [ -f "$desktop_file" ]; then
        echo "Removing web app: $app_name"
        ~/.local/share/omarchy/bin/omarchy-webapp-remove "$app_name" || echo "Warning: Some files for $app_name were already removed"
    else
        echo "Web app $app_name not found, skipping"
    fi
done

# Update desktop database to refresh application launcher
echo "Updating desktop database..."
update-desktop-database ~/.local/share/applications/

echo "Cleanup complete!"
