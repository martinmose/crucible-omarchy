# Personalize Omarchy 🛠️

My personal customization and automation tool for customizes Omarchy with additional packages and my personal dotfiles configuration. This extends the base [Omarchy](https://manuals.omamix.org/2/the-omarchy-manual) setup with my preferred tools and configurations.

## Inspiration

This project is inspired by [Crucible](https://github.com/typecraft-dev/crucible) by [typecraft](https://x.com/typecraft_dev)

## Prerequisites

- Base Omarchy installation (see installation guide below)

## Arch Linux + Omarchy Installation

First, install Arch Linux and Omarchy following the [Getting Started guide](https://manuals.omamix.org/2/the-omarchy-manual/50/getting-started). This will give you the base Omarchy system.

Once you have Omarchy running, this tool adds my personal customizations and additional packages on top of that foundation.

## Setup

### Cloning Repository

1. Install GitHub CLI:
```bash
yay -S github-cli
```

2. Authenticate with GitHub:
```bash
gh auth login
```

3. Clone this repository:
```bash
gh repo clone martinmose/crucible-omarchy
```

3. Navigate to the directory:
```bash
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

## Post-Setup Configuration

### Enable 1Password SSH Agent

After installing 1Password, enable the SSH Agent for seamless Git authentication:

1. Open 1Password
2. Go to **Settings** → **Developer**
3. Enable **Use the SSH agent**
4. Optionally enable **Display key names when authorizing connections**

This allows you to store SSH keys in 1Password and use them automatically for Git operations without manually managing SSH keys.

## Known Issues

### 1Password Developer Mode
The current version doesn't support the rich approval prompt which is enabled by default. If you experience issues with 1Password SSH agent authentication, try disabling the rich approval prompt in 1Password settings under **Settings** → **Developer** → **Rich approval prompt**.

### Brave Browser Setup
After installation, remember to set up Brave sync to synchronize your browser data across devices. Go to **Settings** → **Sync** and enable sync for:
- Extensions
- History
- Settings
- Open tabs
- Saved tab groups
