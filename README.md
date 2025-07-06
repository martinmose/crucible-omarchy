# Personalize Omarchy 🛠️

My personal customization and automation tool for customizes Omarchy with additional packages and my personal dotfiles configuration. This extends the base [Omarchy](https://manuals.omamix.org/2/the-omarchy-manual) setup with my preferred tools and configurations.

## Prerequisites

- Base Omarchy installation (see installation guide below)

## Arch Linux + Omarchy Installation

First, install Arch Linux and Omarchy following the [Getting Started guide](https://manuals.omamix.org/2/the-omarchy-manual/50/getting-started). This will give you the base Omarchy system.

Once you have Omarchy running, this tool adds my personal customizations and additional packages on top of that foundation.

## Setup

### Cloning Private Repository

Since this is a private repository, you'll need to authenticate with GitHub:

1. Authenticate with GitHub:
```bash
gh auth login
```
Choose GitHub.com, HTTPS as the protocol, and authenticate via your browser.

2. Clone this repository:
```bash
gh repo clone martinmose/crucible-omarchy
cd crucible-omarchy
```

### Running the Setup

1. Run the main setup script:

```bash
./run.sh
```

This interactive script will let you choose what to do:
- **Full setup**: Remove unwanted defaults + install additions + setup dotfiles
- **Remove defaults only**: Clean up Omarchy packages you don't want
- **Install additions only**: Add your preferred packages
- **Setup dotfiles only**: Configure personal dotfiles

2. Alternatively, you can run individual scripts:

```bash
# Remove unwanted default Omarchy packages
./uninstall-defaults.sh

# Install additional packages
./install-additions.sh

# Setup personal dotfiles
./dotfiles-setup.sh
```

3. Reboot your system to see the changes.

## What This Does to Omarchy

This personal setup customizes the base Omarchy installation by:

- **Removing unwanted defaults**: Clean up Omarchy packages you don't need
- **Adding missing tools**: Install additional development tools and utilities
- **Personal configuration**: Setup my personal dotfiles and preferences
- **Custom package selections**: Tailored to my specific workflow
- **Extended services**: Additional service configurations

## Post-Setup Configuration

### Enable 1Password SSH Agent

After installing 1Password, enable the SSH Agent for seamless Git authentication:

1. Open 1Password
2. Go to **Settings** → **Developer**
3. Enable **Use the SSH agent**
4. Optionally enable **Display key names when authorizing connections**

This allows you to store SSH keys in 1Password and use them automatically for Git operations without manually managing SSH keys.

### ProtonVPN (Optional)

If you need VPN functionality, you can install ProtonVPN following the [Arch Linux Wiki guide](https://wiki.archlinux.org/title/ProtonVPN).

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
