#!/bin/bash

# Install or update Token Monitor from a pinned source checkout, run on the
# system electron43. The launcher and desktop entry come from the dotfiles.
# See docs/token-monitor-setup.md.

set -euo pipefail

source "$(dirname "$0")/utils.sh"
source "$(dirname "$0")/../additional-packages.conf"

repo="https://github.com/Javis603/token-monitor.git"
dir="${XDG_DATA_HOME:-$HOME/.local/share}/token-monitor"

# npm ci replaces node_modules, which a running widget is loading from.
if pgrep -f -- "$dir" &>/dev/null; then
    echo "Error: Token Monitor is running. Quit it first, then re-run this script."
    exit 1
fi

install_packages electron43

# electron43 is often already present as a dependency of another app. Mark it
# explicit so removing that app does not take Token Monitor's runtime with it.
if ! pacman -Qqe electron43 &>/dev/null; then
    sudo pacman -D --asexplicit electron43
fi

if [ -d "$dir/.git" ]; then
    echo "Updating Token Monitor to $TOKEN_MONITOR_TAG..."
    git -C "$dir" fetch --quiet --depth 1 origin "refs/tags/$TOKEN_MONITOR_TAG"
    git -C "$dir" -c advice.detachedHead=false checkout --quiet --detach FETCH_HEAD
else
    echo "Installing Token Monitor $TOKEN_MONITOR_TAG..."
    git -c advice.detachedHead=false clone --quiet --depth 1 --branch "$TOKEN_MONITOR_TAG" "$repo" "$dir"
fi

actual_commit=$(git -C "$dir" rev-parse HEAD)
if [ "$actual_commit" != "$TOKEN_MONITOR_COMMIT" ]; then
    echo "Error: $TOKEN_MONITOR_TAG resolved to $actual_commit, expected $TOKEN_MONITOR_COMMIT."
    echo "The tag may have been moved upstream. Not installing."
    exit 1
fi

# Runtime dependencies only: Electron comes from pacman, not npm. The upstream
# lockfile is npm's, so this must be npm and not pnpm.
(cd "$dir" && npm ci --omit=dev --no-audit --no-fund)

# Swap in the tokscale build Token Monitor pins (sha256-verified by the script).
(cd "$dir" && node scripts/ensure-vendored-tokscale.js)

echo "Token Monitor $TOKEN_MONITOR_TAG installed in $dir"
