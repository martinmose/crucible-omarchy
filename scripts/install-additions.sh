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
set -euo pipefail

source "$(dirname "$0")/utils.sh"

if [ ! -f "$(dirname "$0")/../additional-packages.conf" ]; then
    echo "Error: additional-packages.conf not found!"
    exit 1
fi

source "$(dirname "$0")/../additional-packages.conf"

required_omarchy_commands=(
    omarchy-webapp-install
    omarchy-theme-set
    omarchy-font-set
    omarchy-install-terminal
    omarchy-mise-install
    omarchy-pkg-add
)

for command in "${required_omarchy_commands[@]}"; do
    if ! command -v "$command" &>/dev/null; then
        echo "Error: Required Omarchy command not found: $command"
        exit 1
    fi
done

echo "Starting system setup..."

legacy_packages=()
for package in "${LEGACY_PACKAGES[@]}"; do
    if is_exact_package_installed "$package"; then
        legacy_packages+=("$package")
    fi
done

if [ ${#legacy_packages[@]} -gt 0 ]; then
    echo "Removing packages replaced by Omarchy 4 equivalents: ${legacy_packages[*]}"
    sudo pacman -Rns --noconfirm "${legacy_packages[@]}"
fi

echo "Updating system..."
omarchy update -y

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

for tool in "${MISE_AI_TOOLS[@]}"; do
    echo "Installing mise-managed AI tool: $tool"
    omarchy-mise-install "$tool"
    MISE_MINIMUM_RELEASE_AGE=0 mise use -g "$tool"
done

echo "Installing development tools..."
echo "  - Language tools..."
install_packages "${DEV_TOOLS_LANGUAGES[@]}"

# Setup Rust after installing rustup
if is_installed "rustup" && ! rustup show &>/dev/null; then
    echo "Setting up Rust toolchain..."
    rustup default stable
fi

echo "  - Neovim tools..."
install_packages "${DEV_TOOLS_NVIM[@]}"

echo "Installing applications..."
install_packages "${APPLICATIONS[@]}"

# Optional installs
echo ""
echo "Optional packages:"
echo "-------------------"

# Optional: Android development tools
if [ ${#DEV_TOOLS_ANDROID[@]} -gt 0 ]; then
    read -p "Would you like to install Android development tools (Android Studio, ktlint)? [y/N]: " install_android
    if [[ "$install_android" =~ ^[Yy]$ ]]; then
        echo "Installing Android development tools..."
        install_packages "${DEV_TOOLS_ANDROID[@]}"
    else
        echo "Skipping Android development tools."
    fi
fi

# Optional: Voice tools (speech-to-text)
if [ ${#VOICE_TOOLS[@]} -gt 0 ]; then
    read -p "Would you like to install voice tools (speech-to-text)? [y/N]: " install_voice
    if [[ "$install_voice" =~ ^[Yy]$ ]]; then
        echo "Installing voice tools..."
        install_packages "${VOICE_TOOLS[@]}"

        # Run voxtype model download if voxtype was installed
        if is_installed "voxtype-bin"; then
            echo "Downloading voxtype speech model..."
            voxtype setup --download || echo "Warning: Failed to download voxtype model"
        fi
    else
        echo "Skipping voice tools."
    fi
fi

# Install pnpm global packages
if [ ${#PNPM_PACKAGES[@]} -gt 0 ] && command -v pnpm &>/dev/null; then
    echo "Installing pnpm global packages..."
    export PNPM_HOME="${PNPM_HOME:-$HOME/.local/share/pnpm}"
    export PATH="$PNPM_HOME:$PNPM_HOME/bin:$PATH"
    export PNPM_CONFIG_GLOBAL_BIN_DIR="$PNPM_HOME"
    for package in "${PNPM_PACKAGES[@]}"; do
        echo "Installing pnpm package: $package"
        pnpm add -g "$package" || echo "Warning: Failed to install pnpm package $package"
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

# Enable and start user services
if [ ${#USER_SERVICES[@]} -gt 0 ]; then
    echo "Enabling and starting user services..."
    for service in "${USER_SERVICES[@]}"; do
        if is_installed "${service}" || is_installed "${service}-bin"; then
            echo "Enabling user service: $service"
            systemctl --user enable --now "$service" || echo "Warning: Failed to enable user service $service"
        fi
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
            omarchy-webapp-install "$app_name" "$app_url" "$icon_url" || echo "Warning: Failed to install $app_name"
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

# Add a Nord background as a user-owned Gruvbox override
nord_bg="${OMARCHY_PATH:-/usr/share/omarchy}/themes/nord/backgrounds/1-city-view.png"
gruvbox_bg_dir="$HOME/.config/omarchy/backgrounds/gruvbox"
gruvbox_nord_bg="$gruvbox_bg_dir/1-city-view.png"

if [ -f "$nord_bg" ] && [ ! -f "$gruvbox_nord_bg" ]; then
    echo "Adding Nord background to Gruvbox theme..."
    mkdir -p "$gruvbox_bg_dir"
    cp "$nord_bg" "$gruvbox_nord_bg" || echo "Warning: Failed to copy Nord background"
else
    echo "Nord background already exists in Gruvbox theme or source not found"
fi

# Set Omarchy theme
echo "Setting Gruvbox theme..."
omarchy-theme-set Gruvbox || echo "Warning: Failed to set theme"

# Set Omarchy font
echo "Setting FiraCode font..."
if [[ $(fc-match -f '%{family}\n' monospace | head -n1) != "FiraCode Nerd Font" ]]; then
    omarchy-font-set "FiraCode Nerd Font" || echo "Warning: Failed to set font"
else
    echo "FiraCode is already the default font."
fi

# Install Ghostty terminal as the last step
echo "Checking Ghostty terminal..."
if [[ ! -f "$HOME/.config/xdg-terminals.list" ]] ||
    ! grep -Fxq "com.mitchellh.ghostty.desktop" "$HOME/.config/xdg-terminals.list"; then
    echo "Installing and setting Ghostty as default terminal..."
    omarchy-install-terminal ghostty || echo "Warning: Failed to install Ghostty terminal"
else
    echo "Ghostty is already the default terminal, skipping installation prompt."
    # Just ensure the package is installed without changing settings
    omarchy-pkg-add ghostty 2>/dev/null || true
fi

echo "Setup complete! You may want to reboot your system."
echo ""
echo "Additional setup available:"
echo "  - Run './scripts/setup-keyd.sh' to configure Danish character shortcuts"
