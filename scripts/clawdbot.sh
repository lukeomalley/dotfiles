#!/bin/bash
set -e

# Install Clawdbot using official installer
# Personal AI assistant that runs on your machine
if ! command -v clawdbot &> /dev/null; then
    echo "Installing Clawdbot..."
    curl -fsSL https://clawd.bot/install.sh | bash
else
    echo "Clawdbot already installed"
fi
