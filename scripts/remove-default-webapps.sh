#!/bin/bash

set -euo pipefail

config="$HOME/.config/omarchy/crucible/uninstall-packages.conf"

if [[ ! -f $config ]]; then
    echo "Crucible web-app removal config not found: $config" >&2
    exit 1
fi

source "$config"

if ! command -v alacritty &>/dev/null; then
    rm -f "$HOME/.local/share/applications/Alacritty.desktop"
fi

for app in "${WEBAPPS[@]}"; do
    app_name="${app%.desktop}"
    desktop_file="$HOME/.local/share/applications/$app"

    if [[ -f "$desktop_file" ]]; then
        OMARCHY_REMOVE_NOTIFY=false omarchy-webapp-remove "$app_name"
    fi
done

if [[ $(xdg-mime query default x-scheme-handler/mailto 2>/dev/null) == "HEY.desktop" ]]; then
    browser=$(xdg-settings get default-web-browser 2>/dev/null || true)
    [[ -n $browser ]] && xdg-mime default "$browser" x-scheme-handler/mailto
fi
