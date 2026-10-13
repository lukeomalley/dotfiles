#!/usr/bin/env bash
set -e

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
[[ "$(uname -s)" == Linux ]] || { echo "Omarchy Linux is required" >&2; exit 1; }

# Omarchy supplies the base desktop/tools. Install only missing additions,
# choosing the configured package repositories before falling back to the AUR.
repo_packages=()
aur_packages=()
while IFS= read -r package; do
    package="${package%%#*}"
    [[ -n "$package" ]] || continue
    pacman -Q "$package" >/dev/null 2>&1 && continue
    if pacman -Si "$package" >/dev/null 2>&1; then
        repo_packages+=("$package")
    else
        aur_packages+=("$package")
    fi
done < "$ROOT/packages/omarchy.txt"

if ((${#repo_packages[@]})); then
    omarchy pkg add "${repo_packages[@]}"
fi
if ((${#aur_packages[@]})); then
    omarchy pkg aur add "${aur_packages[@]}"
fi
