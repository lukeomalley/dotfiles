#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
[[ "$(uname -s)" == Linux ]] || { echo "Omarchy Linux is required" >&2; exit 1; }

privileged() {
    if [[ -t 0 ]]; then sudo "$@"; else pkexec "$@"; fi
}

# Preserve touchpad disable-while-typing when keyd grabs the physical keyboard.
source="$ROOT/system/omarchy/etc/libinput/local-overrides.quirks"
target=/etc/libinput/local-overrides.quirks
if ! cmp -s "$source" "$target"; then
    if [[ -e "$target" ]]; then
        privileged cp -a "$target" "$target.pre-dotfiles.$(date +%Y%m%d-%H%M%S)"
    fi
    privileged install -Dm644 "$source" "$target"
    echo "Libinput quirks updated. Log out and back in to apply them."
fi

# Lid behavior belongs to the host, not every Omarchy laptop.
host="$(uname -n)"
source="$ROOT/system/omarchy/hosts/${host%%.*}/logind-keep-online.conf"
target=/etc/systemd/logind.conf.d/90-dotfiles-keep-online.conf
if [[ -f "$source" ]] && ! cmp -s "$source" "$target"; then
    if [[ -e "$target" ]]; then
        privileged cp -a "$target" "$target.pre-dotfiles.$(date +%Y%m%d-%H%M%S)"
    fi
    privileged install -Dm644 "$source" "$target"
    privileged systemctl reload systemd-logind
    echo "Host lid-closed settings applied."
fi
