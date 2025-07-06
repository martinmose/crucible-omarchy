# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an Arch Linux bootstrap tool that automates the setup of a complete Hyprland development environment. It installs and configures packages, window managers, and utilities using yay as the AUR helper.

## Common Commands

### Main Setup
```bash
# Interactive setup with options for full or partial customization
./run.sh
```

### Individual Scripts
```bash
# Remove unwanted default Omarchy packages
./uninstall-defaults.sh

# Install additional packages
./install-additions.sh

# Clone and setup personal dotfiles
./dotfiles-setup.sh
```


## Architecture

### Core Components

**run.sh**: Main orchestration script that provides interactive options for:
- Removing unwanted default Omarchy packages
- Installing additional packages
- Setting up personal dotfiles
- Full customization workflow

**install-additions.sh**: Package installation script that:
- Installs yay AUR helper
- Installs packages by category using `packages.conf`
- Configures Hyprland window manager environment
- Enables system services

**uninstall-defaults.sh**: Package removal script that:
- Removes unwanted default Omarchy packages
- Cleans up applications you don't use
- Customizable package removal list

**utils.sh**: Shared utility functions:
- `is_installed()`: Check if pacman package exists
- `is_group_installed()`: Check if package group exists  
- `install_packages()`: Install packages via yay if not present

**packages.conf**: Package definitions organized by category:
- `SYSTEM_UTILS`: Core utilities (git, ripgrep, fzf, btop, etc.)
- `DEV_TOOLS`: Development tools (neovim, tmux, lazygit, nodejs, etc.)
- `DESKTOP`: Hyprland and window management (hyprland, dunst, tofi, nemo, etc.)
- `APPLICATIONS`: User applications (firefox, 1password, brave, obsidian)
- `MEDIA`: Media applications (vlc, flameshot, gimp)
- `FONTS`: Font packages (nerd fonts)
- `SERVICES`: System services to enable

### Supporting Scripts

**dotfiles-setup.sh**: Clones the personal dotfiles repository (~/.dotfiles) for additional customization after the main setup is complete.

## Development Notes

### Package Manager
Uses yay for AUR package management. Yay is installed automatically if not present.

### Error Handling
Scripts use `set -e` for strict error handling and check for command existence before installation.

### Package Installation Strategy
Uses intelligent package filtering - checks if packages are already installed before attempting installation to avoid unnecessary operations.

### Private Repository Access
Since this is a private repository, users need to authenticate with GitHub CLI (`gh auth login`) before cloning.