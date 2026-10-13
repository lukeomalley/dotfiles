#!/usr/bin/env bash
set -e

# Install Homebrew, everything in packages/Brewfile, and the Rust toolchain.

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

if [ ! -x /opt/homebrew/bin/brew ]; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

echo "Updating Homebrew..."
brew update

echo "Installing dependencies from Brewfile..."
brew bundle --file="$ROOT/packages/Brewfile"

# rustup ships without a toolchain. Install stable plus rust-analyzer (not in
# the default profile); on an existing machine this just updates stable.
RUSTUP="$(brew --prefix rustup)/bin/rustup"
if [ -x "$RUSTUP" ]; then
    echo "Installing Rust stable toolchain..."
    "$RUSTUP" toolchain install stable --component rust-analyzer
fi

echo "Upgrading packages..."
brew upgrade

echo "Cleaning up..."
brew cleanup

echo "Homebrew setup complete!"
