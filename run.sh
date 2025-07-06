#!/bin/bash

# Print the logo
print_logo() {
  cat <<"EOF"
    ______                _ __    __     
   / ____/______  _______(_) /_  / /__   
  / /   / ___/ / / / ___/ / __ \/ / _ \  
 / /___/ /  / /_/ / /__/ / /_/ / /  __/  Personal Omarchy Setup
 \____/_/   \__,_/\___/_/_.___/_/\___/   by: martinmose 

EOF
}

# Clear screen and show logo
clear
print_logo

echo "Personal Omarchy Customization Setup"
echo "===================================="
echo ""
echo "This will customize your Omarchy installation with:"
echo "1. Remove unwanted default packages"
echo "2. Install additional packages you want"
echo "3. Setup personal dotfiles"
echo ""

# Ask user what they want to do
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

  echo "Step 1: Removing unwanted default packages..."
  ./uninstall-defaults.sh

  echo ""
  echo "Step 2: Installing additional packages..."
  ./install-additions.sh

  echo ""
  echo "Step 3: Setting up dotfiles..."
  ./dotfiles-setup.sh

  echo ""
  echo "Full setup complete! You may want to reboot your system."
  ;;
2)
  echo ""
  echo "Removing unwanted default packages..."
  ./uninstall-defaults.sh
  ;;
3)
  echo ""
  echo "Installing additional packages..."
  ./install-additions.sh
  ;;
4)
  echo ""
  echo "Setting up dotfiles..."
  ./dotfiles-setup.sh
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

