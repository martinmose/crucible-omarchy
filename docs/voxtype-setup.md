# Voxtype Setup

Voxtype is a voice-to-text dictation tool that converts speech input to text. It runs as a user-level systemd service.

## Installation

The install script will prompt you to optionally install voice tools. If you prefer to set it up manually:

1. Install the package:
```bash
sudo pacman -S voxtype-bin
```

2. Download the speech recognition model:
```bash
voxtype setup --download
```

3. Enable and start the service:
```bash
systemctl --user enable --now voxtype
```

## Verify

Check that the service is running:
```bash
systemctl --user status voxtype
```

## Notes

- Voxtype runs as a user service (not system-level), so no `sudo` is needed for the systemctl commands
- The model download (`voxtype setup --download`) is required before the service will work
