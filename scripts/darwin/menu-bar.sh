#!/usr/bin/env bash
set -euo pipefail

# Hide menu bar icons for apps that must keep running (work device management,
# endpoint security). Turns off each app's switch in System Settings > Menu Bar >
# Allow in the Menu Bar, which hides the icon without stopping the app.
#
# macOS keeps these switches in a private, protected file, so this drives the
# System Settings UI with agent-desktop instead of `defaults`. An app appears in
# the list only after it has run once; re-run this script after installing one.

# Names as they appear in the Allow in the Menu Bar list.
HIDDEN=(
    "Rippling Tray"
    "SentinelAgent"
)

PANE="x-apple.systempreferences:com.apple.ControlCenter-Settings.extension"

if ! command -v agent-desktop >/dev/null || ! command -v jq >/dev/null; then
    echo "Skipping menu bar icons: agent-desktop and jq are required (packages/Brewfile)."
    exit 0
fi

if [[ "$(agent-desktop permissions | jq -r .data.accessibility.state)" != granted ]]; then
    echo "Skipping menu bar icons: grant Accessibility first (agent-desktop permissions --guide), then re-run."
    exit 0
fi

find_switch() {
    agent-desktop find --app "System Settings" --role switch --name "$1" --exact --first 2>/dev/null \
        | jq -r '.data.match.ref_id // empty' || true
}

open "$PANE"

# Wait for the pane to load its app list. The pane has two switches of its own;
# every switch beyond those belongs to an app.
for _ in {1..30}; do
    count="$(agent-desktop find --app "System Settings" --role switch --count 2>/dev/null \
        | jq -r '.data.count // 0' || true)"
    (( ${count:-0} > 2 )) && break
    sleep 0.5
done

for name in "${HIDDEN[@]}"; do
    ref="$(find_switch "$name")"
    if [[ -z "$ref" ]]; then
        echo "  $name: not in the list (not installed or never run), skipped"
        continue
    fi
    if agent-desktop uncheck "$ref" >/dev/null; then
        echo "  $name: hidden"
    else
        echo "  $name: failed to turn off its switch"
    fi
done

agent-desktop close-app "System Settings" >/dev/null 2>&1 || true
