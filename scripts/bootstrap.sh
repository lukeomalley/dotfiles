#!/bin/bash
set -e

# Navigate to project root
cd "$(dirname "$0")/.."

# Install Homebrew and packages
echo "Setting up Homebrew..."
./scripts/homebrew.sh

# Stow dotfiles
echo "Stowing dotfiles..."
./scripts/stow.sh

# Sync agent skills into app-specific directories (Codex, Claude, Cursor, OpenCode)
echo "Syncing agent skills..."
if [ -x "$HOME/bin/sync-agent-skills" ]; then
    "$HOME/bin/sync-agent-skills" || echo "Warning: Agent skill sync failed."
else
    echo "Warning: sync-agent-skills script not found in $HOME/bin"
fi

# Configure Keyboard
echo "Configuring keyboard..."
./scripts/keyboard.sh

# Configure macOS settings
echo "Configuring macOS settings..."
./scripts/macos.sh

# Configure Tmux
echo "Configuring tmux..."
./scripts/setup-tmux.sh

# Configure Secrets
echo "Configuring secrets..."
if [ -x "$HOME/bin/update-secrets" ]; then
    "$HOME/bin/update-secrets" || echo "Warning: Secrets configuration failed."
else
    echo "Warning: update-secrets script not found in $HOME/bin"
fi

echo "Bootstrap complete!"
