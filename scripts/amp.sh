#!/bin/bash
set -e

# Install Amp CLI using official installer
# Supports auto-updating and fast launch via Bun
if ! command -v amp &> /dev/null; then
    echo "Installing Amp CLI..."
    curl -fsSL https://ampcode.com/install.sh | bash
else
    echo "Amp CLI already installed"
fi
