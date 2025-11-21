# Mac Configuration Files

Personal dotfiles and configuration scripts for macOS, managed with **GNU Stow** and **Homebrew**.

## Included Configurations
- **Shell**: Zsh with Starship prompt, zoxide, fnm
- **Editor**: Neovim (nvim)
- **Terminal**: Ghostty, iTerm2
- **Tools**: Tmux, Ranger, k9s, rclone, Smug, Git

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/dotfiles.git ~/code/dotfiles
   ```

2. Run the bootstrap script:
   ```bash
   ./scripts/bootstrap.sh
   ```

This script will:
- Install Homebrew and dependencies (via `Brewfile`)
- Symlink configuration files using `stow`
- Apply macOS keyboard settings
