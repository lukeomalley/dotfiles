#!/bin/bash
set -e

TPM_DIR="$HOME/.tmux/plugins/tpm"

echo "Checking for Tmux Plugin Manager (TPM)..."

if [ ! -d "$TPM_DIR" ]; then
    echo "TPM not found. Cloning from github.com/tmux-plugins/tpm..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
    echo "TPM installed successfully!"
else
    echo "TPM is already installed at $TPM_DIR"
fi

echo ""
echo "Setup complete."
echo "To install the plugins defined in your tmux.conf:"
echo "1. Open tmux"
echo "2. Press 'prefix + I' (Control-Space + I in your config)"

