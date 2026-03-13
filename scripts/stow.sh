#!/bin/bash
set -e

# Navigate to dotfiles directory
SCRIPT_DIR="$(dirname "$0")"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT/dotfiles"

# Stow all directories in dotfiles/ to $HOME
# --no-folding: Create symlinks for files only, not directories
#               This prevents runtime files from polluting the dotfiles repo
#               (e.g., Claude writes debug/history/cache files to ~/.claude)
for d in */; do
    [ -d "$d" ] || continue
    echo "Stowing ${d%/}..."
    stow -R --no-folding -t "$HOME" "${d%/}"
done

