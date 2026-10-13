#!/usr/bin/env bash
set -euo pipefail

# Link stow/common, stow/<os> and stow/hosts/<hostname> into $HOME.
# --no-folding links files only, never directories, so app runtime files never
# land in the repo.

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$ROOT/scripts/os.sh"
host="$(uname -n)"

for layer in common "$OS" "hosts/${host%%.*}"; do
    dir="$ROOT/stow/$layer"
    [[ -d "$dir" ]] || continue
    for package in "$dir"/*/; do
        package="$(basename "$package")"
        echo "Stowing $layer/$package..."
        stow -R --no-folding -d "$dir" -t "$HOME" "$package"
    done
done
