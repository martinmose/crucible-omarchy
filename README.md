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

1. Authenticate with GitHub:
```bash
gh auth login
```

2. Clone this repository:
```bash
gh repo clone martinmose/crucible-omarchy
```

3. Navigate to the directory:
```bash
cd crucible-omarchy
```

4. Once everything is set up, switch to SSH for git operations:
```bash
git remote set-url origin git@github.com:martinmose/crucible-omarchy.git
```

5. Also switch the dotfiles repository to SSH:
```bash
cd ~/.dotfiles
git remote set-url origin git@github.com:martinmose/.dotfiles.git
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

### 1Password Setup

After installation, complete the 1Password configuration:

1. **Login to 1Password**: Sign in with your account credentials
2. **Enable SSH Agent**: 
   - Go to **Settings** → **Developer**
   - Enable **Use the SSH agent**
   - Optionally enable **Display key names when authorizing connections**
3. **Enable CLI Access**: 
   - Go to **Settings** → **Developer**
   - Enable **Connect with 1Password CLI**

This allows you to store SSH keys in 1Password and use them automatically for Git operations, plus enables CLI integration for password management.

### Brave Browser Setup

After installation, set up Brave sync to synchronize your browser data:

1. Open Brave Browser
2. Go to **Settings** → **Sync**
3. Set up sync and enable synchronization for:
   - Extensions
   - History
   - Settings
   - Open tabs
   - Saved tab groups

### Obsidian Setup

After installation, remember to login to Obsidian to sync your notes:

1. Open Obsidian
2. Sign in with your Obsidian account
3. Enable sync to access your existing vaults and notes

### Danish Character Setup

For Danish character shortcuts using Alt key combinations, see [keyd-setup.md](keyd-setup.md) for configuration details.

## Customization

### Adding Web Apps

You can add custom web applications that will be installed as desktop applications. Web apps are defined in the `additional-packages.conf` file in the `WEBAPPS` array.

**Format:**
```bash
WEBAPPS=(
  "App Name|URL|Icon URL"
)
```

**Example:**
```bash
WEBAPPS=(
  "Proton Mail|https://mail.proton.me|https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/proton-mail.png"
  ...
)
```

**Finding Icons:**
Icons can be found at [Dashboard Icons](https://dashboardicons.com/). Use the CDN URL format: `https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/[icon-name].png`

## Known Issues

### 1Password Developer Mode
The current version doesn't support the rich approval prompt which is enabled by default. If you experience issues with 1Password SSH agent authentication, try disabling the rich approval prompt in 1Password settings under **Settings** → **Developer** → **Rich approval prompt**.

### OBS with Nvidia Blackwell GPUs
If you experience issues with OBS on Nvidia Blackwell GPUs, this can likely be fixed by installing the open-source Nvidia drivers:

```bash
sudo pacman -S nvidia-open linux linux-headers nvidia-utils nvtop
```

**Important:** Use HDMI instead of DisplayPort for better compatibility.

If issues persist, check the Omarchy Discord for additional troubleshooting steps.

## TODO

- Check if wl-clipboard is already installed by default in Omarchy before adding to packages

