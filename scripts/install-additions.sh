#!/bin/bash

print_logo() {
    cat <<"EOF"
    ______                _ __    __     
   / ____/______  _______(_) /_  / /__   
  / /   / ___/ / / / ___/ / __ \/ / _ \  
 / /___/ /  / /_/ / /__/ / /_/ / /  __/  Omarchy Additional Tool
 \____/_/   \__,_/\___/_/_.___/_/\___/   by: martinmose 

EOF
}

# Clear screen and show logo
clear
print_logo

# Exit on any error
set -e

source "$(dirname "$0")/utils.sh"

if [ ! -f "$(dirname "$0")/../additional-packages.conf" ]; then
    echo "Error: additional-packages.conf not found!"
    exit 1
fi

source "$(dirname "$0")/../additional-packages.conf"

# Omarchy bin directory
OMARCHY_BIN="$HOME/.local/share/omarchy/bin"

echo "Starting system setup..."

echo "Updating system..."
sudo pacman -Syu --noconfirm

echo "Installing system utilities..."
install_packages "${SYSTEM_UTILS[@]}"

# Change default shell to ZSH if it's installed and not already default
if is_installed "zsh" && [ "$SHELL" != "$(which zsh)" ]; then
    echo "Changing default shell to ZSH..."
    chsh -s $(which zsh) || echo "Warning: Failed to change shell to ZSH. You may need to run: chsh -s \$(which zsh)"
else
    echo "ZSH is already the default shell or not installed"
fi

echo "Installing ai tools..."
install_packages "${AI_TOOLS[@]}"

echo "Installing development tools..."
echo "  - Language tools..."
install_packages "${DEV_TOOLS_LANGUAGES[@]}"

# Setup Rust after installing rustup
if is_installed "rustup" && ! rustup show &>/dev/null; then
    echo "Setting up Rust toolchain..."
    rustup default stable
fi

echo "  - Android tools..."
install_packages "${DEV_TOOLS_ANDROID[@]}"


echo "  - Neovim tools..."
install_packages "${DEV_TOOLS_NVIM[@]}"

echo "Installing applications..."
install_packages "${APPLICATIONS[@]}"

# Install NPM packages globally
if [ ${#NPM_PACKAGES[@]} -gt 0 ] && command -v npm &>/dev/null; then
    echo "Installing NPM global packages..."
    for package in "${NPM_PACKAGES[@]}"; do
        echo "Installing npm package: $package"
        sudo npm install -g "$package" || echo "Warning: Failed to install npm package $package"
    done
fi

# Install Cargo packages
if [ ${#CARGO_PACKAGES[@]} -gt 0 ] && command -v cargo &>/dev/null; then
    echo "Installing Cargo packages..."
    for package in "${CARGO_PACKAGES[@]}"; do
        echo "Installing cargo package: $package"
        cargo install "$package" || echo "Warning: Failed to install cargo package $package"
    done
fi

# Enable and start services
if [ ${#SERVICES[@]} -gt 0 ]; then
    echo "Enabling and starting services..."
    for service in "${SERVICES[@]}"; do
        echo "Enabling service: $service"
        sudo systemctl enable --now "$service" || echo "Warning: Failed to enable $service"
    done
fi

# Install web apps using web2app
if [ ${#WEBAPPS[@]} -gt 0 ]; then
    echo "Installing web apps..."
    for webapp in "${WEBAPPS[@]}"; do
        # Parse pipe-separated format: AppName|AppURL|IconURL
        IFS='|' read -r app_name app_url icon_url <<<"$webapp"

        if [ -n "$app_name" ] && [ -n "$app_url" ] && [ -n "$icon_url" ]; then
            echo "Installing web app: $app_name"
            "$OMARCHY_BIN/omarchy-webapp-install" "$app_name" "$app_url" "$icon_url" || echo "Warning: Failed to install $app_name"
        else
            echo "Warning: Invalid webapp format: $webapp"
        fi
    done
fi

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

# Add Nord background to Gruvbox theme
nord_bg="/home/martinmose/.local/share/omarchy/themes/nord/backgrounds/1-nord.png"
gruvbox_bg_dir="/home/martinmose/.local/share/omarchy/themes/gruvbox/backgrounds"
gruvbox_nord_bg="$gruvbox_bg_dir/1-nord.png"

if [ -f "$nord_bg" ] && [ ! -f "$gruvbox_nord_bg" ]; then
    echo "Adding Nord background to Gruvbox theme..."
    cp "$nord_bg" "$gruvbox_bg_dir/" || echo "Warning: Failed to copy Nord background"
else
    echo "Nord background already exists in Gruvbox theme or source not found"
fi

# Set Omarchy theme
echo "Setting Gruvbox theme..."
"$OMARCHY_BIN/omarchy-theme-set" Gruvbox || echo "Warning: Failed to set theme"

# Set Omarchy font
echo "Setting FiraCode font..."
"$OMARCHY_BIN/omarchy-font-set" "FiraCode Nerd Font" || echo "Warning: Failed to set font"

# Install Ghostty terminal as the last step
echo "Checking Ghostty terminal..."
current_terminal=$(grep "export TERMINAL=" ~/.config/uwsm/default 2>/dev/null | cut -d'=' -f2)
if [ "$current_terminal" != "ghostty" ]; then
    echo "Installing and setting Ghostty as default terminal..."
    "$OMARCHY_BIN/omarchy-install-terminal" ghostty || echo "Warning: Failed to install Ghostty terminal"
else
    echo "Ghostty is already the default terminal, skipping installation prompt."
    # Just ensure the package is installed without changing settings
    "$OMARCHY_BIN/omarchy-pkg-add" ghostty 2>/dev/null || true
fi

echo "Setup complete! You may want to reboot your system."
echo ""
echo "Additional setup available:"
echo "  - Run './scripts/setup-keyd.sh' to configure Danish character shortcuts"
