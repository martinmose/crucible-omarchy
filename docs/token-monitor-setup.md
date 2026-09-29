# Token Monitor Setup

[Token Monitor](https://github.com/Javis603/token-monitor) is a desktop widget for token usage and limits across AI coding tools. It is an Electron app with no Arch package, and its only Linux release is an AppImage. Instead, `scripts/install-token-monitor.sh` runs a pinned source checkout on the system `electron43` package:

- Electron comes from pacman (`electron43` in `APPLICATIONS`) and is updated with the system.
- The app is a shallow clone of `TOKEN_MONITOR_TAG` in `~/.local/share/token-monitor`. The script refuses to install if the tag no longer points at `TOKEN_MONITOR_COMMIT`.
- `npm ci --omit=dev` installs only the runtime dependencies from the upstream lockfile, skipping npm's Electron download.
- The app does not self-update when run unpackaged, so this pin is the only update path.

The launcher (`~/.local/bin/token-monitor`) and desktop entry come from the dotfiles.

## Installation

The full setup runs the script after the applications. To run it on its own:
```bash
./scripts/install-token-monitor.sh
```

Then deploy the launcher and desktop entry with `chezmoi apply`, and start Token Monitor from the app launcher.

## Updating

1. Quit Token Monitor. The script refuses to run while it is open.
2. Set `TOKEN_MONITOR_TAG` and `TOKEN_MONITOR_COMMIT` in `additional-packages.conf` to the new release. Get the commit with:
```bash
git ls-remote https://github.com/Javis603/token-monitor.git 'refs/tags/v0.63.1^{}'
```
3. Re-run `./scripts/install-token-monitor.sh`.

Check that the release's Linux build still uses Electron 43 (`TOKEN_MONITOR_LINUX_ELECTRON_VERSION` in its `.github/workflows/release.yml`). If it moves to a new major, switch `electron43` here and in the dotfiles launcher.

## Uninstall

```bash
rm -rf ~/.local/share/token-monitor      # app checkout
rm -rf ~/.config/"Token Monitor"         # settings, credentials and usage archives
```

Remove the launcher and desktop entry from the dotfiles. `electron43` can stay if other apps (Obsidian, Podman Desktop) still need it.

## Notes

- Settings and any provider credentials added in the app live in `~/.config/Token Monitor/`. Credentials are stored in plaintext `credentials.json` (mode `0600`), by upstream design.
- Multi-device sync is configured in the app (Settings, Multi-device Sync) and is off by default.
