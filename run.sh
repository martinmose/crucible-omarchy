#!/bin/bash

print_logo() {
  cat <<"EOF"
    ______                _ __    __     
   / ____/______  _______(_) /_  / /__   
  / /   / ___/ / / / ___/ / __ \/ / _ \  
 / /___/ /  / /_/ / /__/ / /_/ / /  __/  Personal Omarchy Setup
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
  echo "Please run it as a regular user: ./run.sh"
  exit 1
fi

echo "Personal Omarchy Customization Setup"
echo "===================================="
echo ""
echo "This will customize your Omarchy installation with:"
echo "1. Remove unwanted default packages"
echo "2. Install additional packages you want"
echo "3. Setup personal dotfiles"
echo ""

echo "What would you like to do?"
echo "1) Full setup (remove defaults + install additions + setup dotfiles)"
echo "2) Remove unwanted default packages only"
echo "3) Install additional packages only"
echo "4) Setup dotfiles only"
echo "5) Exit"
echo ""

read -p "Enter your choice (1-5): " choice

case $choice in
1)
  echo ""
  echo "Running full setup..."
  echo ""

  echo "Step 1: Creating ~/dev directory..."
  if [ ! -d "$HOME/dev" ]; then
    mkdir -p "$HOME/dev"
    echo "Created ~/dev directory"
  else
    echo "~/dev directory already exists"
  fi

  echo ""
  echo "Step 2: Removing unwanted default packages..."
  if ! ./scripts/uninstall-defaults.sh; then
    echo "ERROR: Failed to remove unwanted packages!"
    exit 1
  fi

  echo ""
  echo "Step 3: Installing additional packages..."
  if ! ./scripts/install-additions.sh; then
    echo "ERROR: Failed to install additional packages!"
    exit 1
  fi

  echo ""
  echo "Step 4: Setting up dotfiles..."
  if ! ./scripts/dotfiles-setup.sh; then
    echo "ERROR: Failed to setup dotfiles!"
    exit 1
  fi

  echo ""
  echo "Full setup complete! You may want to reboot your system."
  ;;
2)
  echo ""
  echo "Removing unwanted default packages..."
  ./scripts/uninstall-defaults.sh
  ;;
3)
  echo ""
  echo "Installing additional packages..."
  ./scripts/install-additions.sh
  ;;
4)
  echo ""
  echo "Setting up dotfiles..."
  ./scripts/dotfiles-setup.sh
  ;;
5)
  echo "Exiting..."
  exit 0
  ;;
*)
  echo "Invalid choice. Exiting..."
  exit 1
  ;;
esac
