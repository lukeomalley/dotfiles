#!/bin/bash
set -e

# Navigate to project root
cd "$(dirname "$0")/.."

# Install Homebrew if not installed
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for this session
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Update Homebrew
echo "Updating Homebrew..."
brew update

# Install/upgrade dependencies from Brewfile
echo "Installing dependencies from Brewfile..."
brew bundle --file=Brewfile

# rustup ships without a toolchain. Install stable plus rust-analyzer (not in
# the default profile); on an existing machine this just updates stable.
RUSTUP="$(brew --prefix rustup)/bin/rustup"
if [ -x "$RUSTUP" ]; then
    echo "Installing Rust stable toolchain..."
    "$RUSTUP" toolchain install stable --component rust-analyzer
fi

# Upgrade existing packages
echo "Upgrading packages..."
brew upgrade

# Cleanup old versions
echo "Cleaning up..."
brew cleanup

echo "Homebrew setup complete!"

