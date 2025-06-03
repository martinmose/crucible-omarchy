# Arch Linux Bootstrap 🛠️

An Arch Linux system automation tool that sets up a complete Hyprland development environment. It installs and configures packages, window managers, and various utilities to create a fully functional development setup.

## Features

- 🔄 Automated system updates
- 📦 Package installation using paru AUR helper
- 🖥️ Hyprland window manager setup
- 🛠️ Development tools and utilities
- ⚙️ Automatic service configuration
- 🔧 Dotfiles integration for personalized configuration

## Prerequisites

- A fresh Arch Linux installation
- Internet connection
- sudo privileges

## Arch Linux Installation

Install Arch Linux using `archinstall` - see the [Typecraft YouTube video](https://www.youtube.com/watch?v=8YE1LlTxfMQ) for detailed instructions.

## Setup

### Cloning Private Repository

Since this is a private repository, you'll need to authenticate with GitHub:

1. Install GitHub CLI:
```bash
sudo pacman -S github-cli
```

2. Authenticate with GitHub:
```bash
gh auth login
```
Choose GitHub.com, HTTPS as the protocol, and authenticate via your browser.

3. Clone this repository:
```bash
gh repo clone martinmose/crucible-arch
cd crucible-arch
```

### Running the Setup

1. Run the setup script:

```bash
./run.sh
```

2. After the setup is complete, set up your dotfiles:

```bash
./dotfiles-setup.sh
```

This will clone and configure your personal dotfiles repository for additional customization.

3. Reboot your system to see the changes.

## System Setup

I use a dual boot setup between Windows and Arch Linux using GRUB bootloader. This allows me to switch between Windows (for gaming) and Linux (for development) while maintaining separate environments for each purpose.

### Recovery Mode

If you encounter issues with your Linux installation, you can access recovery mode through GRUB:

1. **Enter Recovery Mode:**
   * Restart your computer
   * In the GRUB menu, highlight the default Arch Linux entry
   * Press **'e'** to edit the boot parameters
   * Locate the line starting with `linux` and append `single` at the end
   * Press **Ctrl + X** to boot with these parameters

This will boot you into a recovery shell with root access, which can be invaluable for fixing system issues, resetting configurations, or recovering from boot problems.

## Post-Setup Configuration

### Fix Fractional Scaling

Run and edit .desktop files for applications that do not support fractional scaling. For example, for Slack:

```bash
sudo vim /usr/share/applications/slack.desktop
```

Update the Exec line:
```
Exec=/usr/bin/slack --ozone-platform=wayland --enable-features=UseOzonePlatform --enable-features=WebRTCPipeWireCapturer --enable-features=WaylandWindowDecorations %U
```

See: https://www.reddit.com/r/hyprland/comments/1jfo3rj/text_rendering_blurry_after_updates_hyprland/
