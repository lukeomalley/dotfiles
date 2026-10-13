#!/usr/bin/env bash
set -e

# Set up this machine. Every step is safe to re-run.

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$ROOT/scripts/os.sh"

echo "Installing packages..."
"$ROOT/scripts/$OS/packages.sh"
# Make Homebrew (installed just now on a fresh Mac) available to later steps.
[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

echo "Stowing dotfiles..."
"$ROOT/scripts/stow.sh"

echo "Setting up Git keys..."
"$ROOT/scripts/git-keys.sh"

echo "Setting up agent skills..."
"$ROOT/scripts/agent-skills.sh" || echo "Warning: Agent skills setup failed."

echo "Applying $OS settings..."
"$ROOT/scripts/$OS/settings.sh"

echo "Setting up tmux..."
"$ROOT/scripts/setup-tmux.sh"

echo "Generating secrets..."
"$HOME/bin/update-secrets" || echo "Warning: Secrets setup failed."

echo "Checking the result..."
"$ROOT/scripts/check.sh" || echo "Fix the failed checks above, then re-run scripts/check.sh."
