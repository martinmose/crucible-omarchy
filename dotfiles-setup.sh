#!/bin/bash

print_logo() {
  cat <<"EOF"
    ______                _ __    __     
   / ____/______  _______(_) /_  / /__   
  / /   / ___/ / / / ___/ / __ \/ / _ \  
 / /___/ /  / /_/ / /__/ / /_/ / /  __/  Dotfiles Setup Tool
 \____/_/   \__,_/\___/_/_.___/_/\___/   by: martinmose 

EOF
}

clear
print_logo

# Exit on any error
set -e

ORIGINAL_DIR=$(pwd)
REPO_URL="https://github.com/martinmose/.dotfiles"
REPO_NAME=".dotfiles"
DOTFILES_DIR="$HOME/$REPO_NAME"

echo "Setting up personal dotfiles..."

# Check if the repository already exists
if [ -d "$DOTFILES_DIR" ]; then
  echo "Repository '$REPO_NAME' already exists. Pulling latest changes..."
  cd "$DOTFILES_DIR"
  git pull origin main
else
  echo "Cloning dotfiles repository..."
  gh repo clone martinmose/.dotfiles "$DOTFILES_DIR"
fi

# Check if the clone was successful
if [ $? -eq 0 ]; then
  echo "Repository ready. Running dotfile installation script..."
  cd "$DOTFILES_DIR"

  ./dotfile-script.sh omarchy

  echo ""
  echo "Dotfiles installed successfully!"
  echo ""

  cd "$ORIGINAL_DIR"
else
  echo "Failed to setup dotfiles repository."
  exit 1
fi
