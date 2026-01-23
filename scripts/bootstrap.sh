#!/bin/bash
set -e

# Navigate to project root
cd "$(dirname "$0")/.."

# Install Homebrew and packages
echo "Setting up Homebrew..."
./scripts/homebrew.sh

# Install Amp CLI
echo "Installing Amp CLI..."
./scripts/amp.sh

# Stow dotfiles
echo "Stowing dotfiles..."
./scripts/stow.sh

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

