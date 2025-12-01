#!/bin/bash
set -e

# Navigate to project root
cd "$(dirname "$0")/.."

# Install Homebrew if not installed
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install dependencies
echo "Installing dependencies from Brewfile..."
brew bundle --file=Brewfile

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

