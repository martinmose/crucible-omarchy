# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an Arch Linux bootstrap tool that automates the setup of a complete Hyprland development environment. It installs and configures packages, window managers, and utilities using paru as the AUR helper.

## Common Commands

### Main Setup
```bash
# Full system setup (Hyprland + all packages)
./run.sh
```

### Dotfiles Setup
```bash
# Clone and setup personal dotfiles after main setup
./dotfiles-setup.sh
```


## Architecture

### Core Components

**run.sh**: Main orchestration script that:
- Installs paru AUR helper
- Installs packages by category using `packages.conf`
- Configures Hyprland window manager environment
- Enables system services

**utils.sh**: Shared utility functions:
- `is_installed()`: Check if pacman package exists
- `is_group_installed()`: Check if package group exists  
- `install_packages()`: Install packages via paru if not present

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
Uses paru instead of yay for AUR package management. Paru is installed automatically if not present.

### Error Handling
Scripts use `set -e` for strict error handling and check for command existence before installation.

### Package Installation Strategy
Uses intelligent package filtering - checks if packages are already installed before attempting installation to avoid unnecessary operations.

### Private Repository Access
Since this is a private repository, users need to authenticate with GitHub CLI (`gh auth login`) before cloning.