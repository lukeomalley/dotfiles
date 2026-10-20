#!/usr/bin/env bash
set -euo pipefail

# Install a tested upstream revision as runtime files, outside Stow packages.
# shell.json and bindings.lua own activation and the default launcher shortcut.
revision=107484e4836195e89d50975568c6ee75c6c51853
install_version="$revision-compat-1"
script_dir="$(cd "$(dirname "$0")" && pwd)"
omarchy_dir="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy"
plugin_dir="$omarchy_dir/plugins/typecraft.oma-cast-managed"

command -v omarchy-shell >/dev/null
command -v socat >/dev/null

if [[ -L "$plugin_dir" ]]; then
    echo "Refusing to replace an existing plugin symlink: $plugin_dir" >&2
    exit 1
fi

if [[ ! -f "$plugin_dir/.dotfiles-revision" ||
      "$(cat "$plugin_dir/.dotfiles-revision")" != "$install_version" ]]; then
    if [[ -e "$plugin_dir" && ! -f "$plugin_dir/.dotfiles-revision" ]]; then
        echo "Existing unmanaged plugin at $plugin_dir; move it aside first." >&2
        exit 1
    fi

    mkdir -p "$omarchy_dir"
    staging="$(mktemp -d "$omarchy_dir/.oma-cast.XXXXXX")"
    trap 'rm -rf -- "$staging"' EXIT
    git clone --quiet https://github.com/typecraft-dev/oma-cast.git "$staging/source"
    git -C "$staging/source" checkout --quiet --detach "$revision"
    # Omarchy 4.0.5 has Quickshell IPC but not the newer ShellIpc wrapper.
    # Keep the upstream target/methods, using the installed shell's transport.
    if [[ ! -f "${OMARCHY_PATH:-/usr/share/omarchy}/shell/Commons/ShellIpc.qml" ]]; then
        sed -i '/^import Quickshell$/a import Quickshell.Io' "$staging/source/plugin/Launcher.qml"
        sed -i 's/^  ShellIpc {/  IpcHandler {/' "$staging/source/plugin/Launcher.qml"
    fi
    if [[ ! -f "${OMARCHY_PATH:-/usr/share/omarchy}/shell/Ui/OverlayWindow.qml" ]]; then
        cp "$script_dir/oma-cast/CompatOverlayWindow.qml" "$staging/source/plugin/ui/"
        sed -i 's/^OverlayWindow {/CompatOverlayWindow {/' "$staging/source/plugin/ui/LauncherWindow.qml"
    fi
    printf '%s\n' "$install_version" > "$staging/source/plugin/.dotfiles-revision"

    mkdir -p "$(dirname "$plugin_dir")"
    if [[ -d "$plugin_dir" ]]; then
        backup="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-backup/oma-cast-$(date +%Y%m%d-%H%M%S)"
        mkdir -p "$(dirname "$backup")"
        mv "$plugin_dir" "$backup"
        echo "Previous plugin saved to $backup"
    fi
    # Publish the complete directory at once so the shell cannot load half a copy.
    mv "$staging/source/plugin" "$plugin_dir"
    echo "Installed oma-cast at $revision"
fi

if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
    omarchy-shell -q shell rescanPlugins
    for ((attempt = 0; attempt < 50; attempt++)); do
        if [[ "$(omarchy-shell oma-cast ping 2>/dev/null)" == ok ]]; then
            echo "oma-cast is running"
            exit 0
        fi
        sleep 0.1
    done
    echo "oma-cast did not respond. Check shell.json is stowed and restart the shell." >&2
    exit 1
fi
echo "oma-cast will load on the next Omarchy login."
