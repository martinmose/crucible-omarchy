#!/usr/bin/env bash
set -euo pipefail

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

REPO_USER="martinmose"
REPO_NAME=".dotfiles"
DOTFILES_DIR="$HOME/$REPO_NAME"

echo "Setting up personal dotfiles..."

# Ensure chezmoi is installed
if ! command -v chezmoi >/dev/null 2>&1; then
    echo "Installing chezmoi..."
    yay -S --noconfirm chezmoi
fi

# Clone or update the dotfiles repository
if [[ -d "$DOTFILES_DIR" ]]; then
    echo "Repository '$REPO_NAME' already exists. Pulling latest changes..."
    git -C "$DOTFILES_DIR" pull origin main
else
    echo "Cloning dotfiles repository..."
    gh repo clone "$REPO_USER/$REPO_NAME" "$DOTFILES_DIR"
fi

# Create chezmoi config pointing to the repo
mkdir -p "$HOME/.config/chezmoi"
if [[ ! -f "$HOME/.config/chezmoi/chezmoi.toml" ]]; then
    cat > "$HOME/.config/chezmoi/chezmoi.toml" << 'EOF'
sourceDir = "~/.dotfiles"
EOF
    echo "Created chezmoi config at ~/.config/chezmoi/chezmoi.toml"
fi

# Apply dotfiles
echo "Applying dotfiles with chezmoi..."
chezmoi apply -v

echo ""
echo "Dotfiles installed successfully!"
echo ""
