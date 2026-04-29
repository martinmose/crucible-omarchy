# Syncthing Setup

[Syncthing](https://syncthing.net/) is a continuous file synchronization program that syncs files between devices in real-time over a peer-to-peer encrypted connection.

## Installation

Syncthing is installed automatically via `additional-packages.conf` and the user service is enabled via the `USER_SERVICES` array.

Manual install if needed:

```bash
yay -S syncthing
systemctl --user enable --now syncthing.service
```

## Initial Setup on a New Machine

1. **Access the Web UI** at http://127.0.0.1:8384 after the service is running.

2. **Get the Device ID** from Actions > Show ID (or the QR code).

3. **Add remote devices** — On an existing machine, go to Add Remote Device and enter the new machine's Device ID (and vice versa). Both devices must add each other.

4. **Share folders** — Once devices are paired, select which folders to share with the new device. The remote device will receive a prompt to accept.

## Useful Commands

```bash
# Check service status
systemctl --user status syncthing.service

# View logs
journalctl --user -u syncthing.service -f

# Restart service
systemctl --user restart syncthing.service
```

## Using with Tailscale

Syncthing works over Tailscale out of the box. Devices on the same Tailscale network (100.x.x.x) will discover each other automatically.

To force traffic over Tailscale (instead of local network or relays), set the device address explicitly in the Web UI:

```
tcp://100.x.x.x:22000
```

Replace `100.x.x.x` with the device's Tailscale IP (find it with `tailscale ip`).

## Notes

- Syncthing discovers peers over the local network and via relay servers automatically.
- No port forwarding is required, but opening TCP port 22000 and UDP port 21027 improves direct connections.
- Configuration lives in `~/.local/state/syncthing/` (or `~/.config/syncthing/` on older setups).
- The Web UI can be secured with a username/password under Settings > GUI.
