# Fixing Electron App Scaling Issues on Hyprland

## Problem
Electron-based applications (Slack, Spotify, Discord, etc.) appear overly zoomed/scaled when launched through app launchers in Hyprland.

## Solution
Create local desktop entry overrides with the `--force-device-scale-factor=1` flag.

## Steps

### 1. Find the system desktop entry
```bash
find /usr/share/applications -name "*app-name*"
```

### 2. Create local override
Create a file in `~/.local/share/applications/` with the same name as the system desktop entry.

### 3. Add the scaling flag
Copy the system desktop entry content and modify the `Exec` line to include:
```
--force-device-scale-factor=1
```

## Examples

### Slack
File: `~/.local/share/applications/slack.desktop`
```ini
Exec=/usr/bin/slack --gtk-version=3 --force-device-scale-factor=1 -s %U
```

### Spotify
File: `~/.local/share/applications/spotify.desktop`
```ini
Exec=spotify --force-device-scale-factor=1 --uri=%u
```

## Notes
- The local desktop entry takes precedence over the system one
- Restart the application after creating the override
- Adjust the scale factor value if needed (0.8, 1.2, etc.)
- This affects app launcher usage, not terminal aliases