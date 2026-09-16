# Elgato Setup (OpenDeck + OpenXLR)

[OpenDeck](https://github.com/nekename/OpenDeck) is a Linux controller for the Elgato Stream Deck. [OpenXLR](https://github.com/emaspa/openxlr) is a control suite and PipeWire submixer for the Elgato XLR interfaces (Wave XLR, XLR Dock) and ships a Stream Deck plugin for OpenDeck. Both are AUR packages, bundled as one optional group in `additional-packages.conf` (`ELGATO_TOOLS`) because they only make sense on machines with the hardware.

## Installation

The install script will prompt you to optionally install Elgato tools. If you prefer to set it up manually:

1. Install the packages:
```bash
yay -S opendeck-bin openxlr
```

2. Replug the XLR interface once so the udev rule applies.

3. Enable and start the OpenXLR daemon:
```bash
systemctl --user enable --now openxlr-daemon
```

4. Register the OpenXLR plugin with OpenDeck:
```bash
mkdir -p ~/.config/opendeck/plugins
cp -r /usr/share/openxlr/com.emaspa.openxlr.sdPlugin ~/.config/opendeck/plugins/
```

## Verify

Check that the daemon is running, then open the mixer from the application menu or with `openxlr`:
```bash
systemctl --user status openxlr-daemon
```

## Notes

- Both run as user services or apps, so no `sudo` is needed for the systemctl commands.
- The pipewire-pulse open-file limit drop-in that OpenXLR installs applies at the next login. To apply it now:
```bash
systemctl --user daemon-reload && systemctl --user restart pipewire-pulse
```
- `swh-plugins` is an optional dependency that provides a software ClipGuard for the XLR Dock.
