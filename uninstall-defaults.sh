#!/bin/bash

# Print the logo
print_logo() {
  cat <<"EOF"
    ______                _ __    __     
   / ____/______  _______(_) /_  / /__   
  / /   / ___/ / / / ___/ / __ \/ / _ \  
 / /___/ /  / /_/ / /__/ / /_/ / /  __/  Omarchy Cleanup Tool
 \____/_/   \__,_/\___/_/_.___/_/\___/   by: martinmose 

EOF
}

# Clear screen and show logo
clear
print_logo

# Exit on any error
set -e

# Source utility functions
source utils.sh

echo "Removing unwanted default Omarchy packages..."

# Define packages to remove (common Omarchy defaults you might not want)
# Uncomment the ones you want to remove
PACKAGES_TO_REMOVE=(
  # Office/Productivity (if you prefer alternatives)
  # "libreoffice-fresh"

  # Media applications (if you have preferences)
  # "vlc"
  # "obs-studio"
  # "kdenlive"

  # Image editing (if you prefer alternatives)
  # "pinta"
  # "gimp"

  # Communication (if you use different apps)
  # "signal-desktop"

  # Note taking (if you prefer alternatives)
  # "obsidian"

  # Games/Entertainment (if not needed)
  # "steam"

  # Development tools you might not use
  # "code"  # VS Code
  # "docker"
  # "docker-compose"

  # Web browsers (keep only your preferred one)
  # "firefox"
  # "chromium"

  # Packages to remove (uncommented = will be removed)
  "typora"  # Markdown editor (commercial)
  "dropbox" # Cloud storage
  "zoom"    # Video conferencing

  # Add more unwanted packages here
)

# Function to remove packages
remove_packages() {
  local packages=("$@")
  local to_remove=()

  for pkg in "${packages[@]}"; do
    if is_installed "$pkg"; then
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

# Function to remove web apps (desktop files)
remove_web_apps() {
  local web_apps_dir="$HOME/.local/share/applications"
  local web_apps=(
    "WhatsApp.desktop"
    "HEY Email.desktop"
    "HEY Calendar.desktop"
    "Basecamp.desktop"
  )

  echo "Removing Omarchy web apps..."

  for app in "${web_apps[@]}"; do
    local app_path="$web_apps_dir/$app"
    if [ -f "$app_path" ]; then
      echo "Removing web app: $app"
      rm "$app_path"
    fi
  done
}

# Remove packages if any are defined
if [ ${#PACKAGES_TO_REMOVE[@]} -ne 0 ]; then
  remove_packages "${PACKAGES_TO_REMOVE[@]}"
else
  echo "No packages configured for removal."
  echo "Edit this script and uncomment packages you want to remove."
fi

# Remove web apps
remove_web_apps

echo "Cleanup complete!"

