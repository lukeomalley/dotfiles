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

echo "Bootstrap complete!"

