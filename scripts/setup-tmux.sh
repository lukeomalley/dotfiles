#!/bin/bash
set -e

# TPM and its plugins live next to tmux.conf, outside the dotfiles repo.
TPM_DIR="$HOME/.config/tmux/plugins/tpm"

if [ ! -d "$TPM_DIR" ]; then
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

"$TPM_DIR/bin/install_plugins"
"$TPM_DIR/bin/update_plugins" all
