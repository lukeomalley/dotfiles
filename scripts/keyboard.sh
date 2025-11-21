#!/bin/bash
set -e

echo "Configuring keyboard repeat rate..."

# Set a really fast key repeat.
# Normal minimum is 15 (225 ms) for initial and 2 (30 ms) for subsequent.
# We'll go faster.
defaults write -g InitialKeyRepeat -int 10
defaults write -g KeyRepeat -int 1

# Disable press-and-hold for special keys in favor of key repeat
defaults write -g ApplePressAndHoldEnabled -bool false

echo "Keyboard settings updated. You may need to log out and back in for changes to take effect."

