# WireView Setup (wireview-hwmon)

[wireview-hwmon](https://github.com/emaspa/wireview-hwmon) is an unofficial Linux driver for the Thermal Grizzly WireView Pro II GPU power monitor (standard and Noctua Edition), by the same author as OpenXLR. `wireviewd` reads the device over USB serial (`0483:5740`) and feeds the `wireview_hwmon` kernel module, which exposes per-pin voltage, current and power, temperatures, fan duty and fault alarms through hwmon. Both are AUR packages, bundled as one optional group in `additional-packages.conf` (`WIREVIEW_TOOLS`) because they only make sense on machines with the hardware.

## Installation

The install script will prompt you to optionally install WireView tools. If you prefer to set it up manually:

1. Install the packages (DKMS builds the module against the installed kernel headers):
```bash
yay -S wireview-hwmon wireview-hwmon-dkms
```

2. Enable and start the daemon. The unit loads the `wireview_hwmon` module first, and the package also loads it at boot:
```bash
sudo systemctl enable --now wireviewd
```

## Verify

```bash
sensors 'wireview-*'
wireviewctl info    # edition, firmware build
wireviewctl top     # live terminal dashboard
```

The hwmon index (`/sys/class/hwmon/hwmonN`) is not stable across boots. Find the device by name instead:
```bash
grep -l '^wireview$' /sys/class/hwmon/*/name
```

## Notes

- Reading sensors needs no group. Privileged commands (`flash`, `nvm`, `write-config`, `bootloader`) need root or the `wireview` group. The package rewrites the udev rule to Arch's `uucp` serial group, which only matters for direct serial access over SSH (e.g. the GUI app).
- The unsigned DKMS module loads under Omarchy's sbctl Secure Boot setup because kernel lockdown is off (`cat /sys/kernel/security/lockdown` shows `[none]`).
- The LAN listener in `/etc/wireview/config` is off by default. Keep it off: when enabled it binds all interfaces, serves sensor and config reads without auth over plain HTTP, and signs writes with the raw passphrase as the HMAC key.
- The command socket `/run/wireviewd.sock` is mode `0666`, so any local user can clear the device's fault status and log, read its config and switch its screen.
- `wireviewctl flash` uses the bundled Thermal Grizzly image by default. Only flash that image or a trusted file on disk, never a pipe or process substitution.
- The optional GUI is `wireview-linux-bin` (1.3.0.0+ for the Noctua Edition).
