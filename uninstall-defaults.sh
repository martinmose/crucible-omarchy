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

source utils.sh

echo "Removing unwanted default Omarchy packages..."

# Define packages to remove (common Omarchy defaults you might not want)
PACKAGES_TO_REMOVE=(
  "alacritty"
  "typora"
  "dropbox"
  "zoom"
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
    sudo yay -Rns --noconfirm "${to_remove[@]}"
  else
    echo "No packages to remove (none are installed)"
  fi
}

# Function to remove web apps (desktop files)
remove_web_apps() {
  local web_apps_dir="$HOME/.local/share/applications"
  local web_apps=(
    "WhatsApp.desktop"
    "HEY.desktop"
    "Basecamp.desktop"
    "Google Contacts.desktop"
    "Google Photos.desktop"
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
