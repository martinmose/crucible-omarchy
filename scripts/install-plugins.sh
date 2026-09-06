#!/bin/bash

print_logo() {
    cat <<"LOGO"
    ______                _ __    __     
   / ____/______  _______(_) /_  / /__   
  / /   / ___/ / / / ___/ / __ \/ / _ \  
 / /___/ /  / /_/ / /__/ / /_/ / /  __/  Omarchy Plugin Installer
 \____/_/   \__,_/\___/_/_.___/_/\___/   by: martinmose 

LOGO
}

clear
print_logo

set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
conf="$script_dir/../plugins.conf"

if [ ! -f "$conf" ]; then
    echo "Error: plugins.conf not found!"
    exit 1
fi

source "$conf"

required_omarchy_commands=(
    omarchy-plugin-add
    omarchy-plugin-enable
    omarchy-plugin-list
)

for command in "${required_omarchy_commands[@]}"; do
    if ! command -v "$command" &>/dev/null; then
        echo "Error: Required Omarchy command not found: $command"
        echo "Plugins need Omarchy 4 or later."
        exit 1
    fi
done

PLUGINS_DIR="$HOME/.config/omarchy/plugins"

plugin_enabled() {
    omarchy-plugin-list --json 2>/dev/null |
        jq -e --arg id "$1" 'any(.[]; .id == $id and .enabled)' >/dev/null
}

if [ ${#PLUGINS[@]} -eq 0 ]; then
    echo "No plugins configured in plugins.conf."
    exit 0
fi

echo "Installing Omarchy plugins..."
failed=()

for entry in "${PLUGINS[@]}"; do
    IFS='|' read -r id url scope post_install <<<"$entry"

    if [ -z "$id" ] || [ -z "$url" ]; then
        echo "Warning: Invalid plugin entry (need id|url|scope|post-install): $entry"
        continue
    fi

    scope="${scope:-all}"
    case "$scope" in
    all) ;;
    optional)
        read -p "Install optional plugin '$id' ($url)? [y/N]: " answer
        if [[ ! "$answer" =~ ^[Yy]$ ]]; then
            echo "Skipping $id."
            continue
        fi
        ;;
    *)
        echo "Warning: Unknown scope '$scope' for $id (use 'all' or 'optional'). Skipping."
        continue
        ;;
    esac

    echo ""
    echo "Plugin: $id"

    fresh_install=false
    if [ -d "$PLUGINS_DIR/$id" ]; then
        echo "  Already installed at $PLUGINS_DIR/$id"
    else
        echo "  Adding from $url"
        # --yes skips the interactive trust prompt; the list in plugins.conf is
        # the reviewed set. --enable places the widget in its default section.
        if ! omarchy-plugin-add "$url" --enable --yes; then
            echo "  Warning: Failed to add $id"
            failed+=("$id")
            continue
        fi
        fresh_install=true

        if [ ! -d "$PLUGINS_DIR/$id" ]; then
            echo "  Warning: Plugin was added but not under the expected id '$id'."
            echo "  Check the 'id' in the plugin's manifest.json and fix plugins.conf."
            failed+=("$id")
            continue
        fi
    fi

    if plugin_enabled "$id"; then
        echo "  Enabled."
    else
        echo "  Enabling..."
        omarchy-plugin-enable "$id" || echo "  Warning: Failed to enable $id"
    fi

    if [ -n "$post_install" ]; then
        post_install_path="$PLUGINS_DIR/$id/$post_install"
        if [ "$fresh_install" = true ]; then
            if [ -x "$post_install_path" ]; then
                echo "  Running post-install: $post_install"
                "$post_install_path" || {
                    echo "  Warning: Post-install script failed for $id"
                    failed+=("$id")
                }
            else
                echo "  Warning: Post-install script not found or not executable: $post_install_path"
            fi
        else
            echo "  Post-install skipped (already installed). Re-run manually with:"
            echo "    $post_install_path"
        fi
    fi
done

echo ""
if [ ${#failed[@]} -gt 0 ]; then
    echo "Plugin setup finished with problems: ${failed[*]}"
    exit 1
fi

echo "Plugin setup complete. Installed plugins:"
omarchy-plugin-list 2>/dev/null | awk 'NR == 1 || $3 == "third-party"'
