#!/bin/bash
set -e

echo "Configuring macOS settings..."

# =============================================================================
# Animation Settings
# =============================================================================

# opening and closing windows and popovers
defaults write -g NSAutomaticWindowAnimationsEnabled -bool false

# smooth scrolling
defaults write -g NSScrollAnimationEnabled -bool false

# showing and hiding sheets, resizing preference windows, zooming windows
# float 0 doesn't work
defaults write -g NSWindowResizeTime -float 0.001

# opening and closing Quick Look windows
defaults write -g QLPanelAnimationDuration -float 0

# rubberband scrolling (doesn't affect web views)
defaults write -g NSScrollViewRubberbanding -bool false

# resizing windows before and after showing the version browser
# also disabled by NSWindowResizeTime -float 0.001
defaults write -g NSDocumentRevisionsWindowTransformAnimation -bool false

# showing a toolbar or menu bar in full screen
defaults write -g NSToolbarFullScreenAnimationDuration -float 0

# scrolling column views
defaults write -g NSBrowserColumnAnimationSpeedMultiplier -float 0

# showing the Dock
defaults write com.apple.dock autohide-time-modifier -float 0
defaults write com.apple.dock autohide-delay -float 0

# showing and hiding Mission Control, command+numbers
defaults write com.apple.dock expose-animation-duration -float 0

# showing and hiding Launchpad
defaults write com.apple.dock springboard-show-duration -float 0
defaults write com.apple.dock springboard-hide-duration -float 0

# changing pages in Launchpad
defaults write com.apple.dock springboard-page-duration -float 0

# at least AnimateInfoPanes
defaults write com.apple.finder DisableAllAnimations -bool true

# sending messages and opening windows for replies
# Note: Mail is sandboxed on newer macOS, these may fail silently
defaults write com.apple.Mail DisableSendAnimations -bool true 2>/dev/null || true
defaults write com.apple.Mail DisableReplyAnimations -bool true 2>/dev/null || true

# =============================================================================
# AeroSpace Tiling Window Manager Settings
# https://nikitabobko.github.io/AeroSpace/guide
# =============================================================================

# Disable "Displays have separate Spaces" for better multi-monitor support
# This fixes focus issues, performance problems, and weird behaviors with AeroSpace
# NOTE: Requires logout to take effect
defaults write com.apple.spaces spans-displays -bool true

# Fix Mission Control grouping - helps with AeroSpace's hidden windows
defaults write com.apple.dock expose-group-apps -bool true

# Move windows by holding ctrl+cmd and dragging any part of the window
defaults write -g NSWindowShouldDragOnGesture -bool true

# Free cmd+ctrl+f for Ghostty quick terminal by moving the macOS fullscreen
# menu shortcut to a chord that is unlikely to be pressed accidentally.
defaults write -g NSUserKeyEquivalents -dict-add "Enter Full Screen" '@~^$f'
defaults write -g NSUserKeyEquivalents -dict-add "Exit Full Screen" '@~^$f'
defaults write -g NSUserKeyEquivalents -dict-add "Toggle Full Screen" '@~^$f'

# =============================================================================
# Screenshot Hotkeys
# =============================================================================

# Disable cmd+shift+3 (save screen as file, key 28) and cmd+shift+4
# (save selected area as file, key 30). The clipboard variants
# (cmd+shift+ctrl+3/4) and cmd+shift+5 (Screenshot app) stay enabled.
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 28 '<dict><key>enabled</key><false/><key>value</key><dict><key>parameters</key><array><integer>51</integer><integer>20</integer><integer>1179648</integer></array><key>type</key><string>standard</string></dict></dict>'
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 30 '<dict><key>enabled</key><false/><key>value</key><dict><key>parameters</key><array><integer>52</integer><integer>21</integer><integer>1179648</integer></array><key>type</key><string>standard</string></dict></dict>'

# =============================================================================
# Apply Changes
# =============================================================================

# Restart affected services
killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true
killall SystemUIServer 2>/dev/null || true

# Reload symbolic hotkeys without requiring logout
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u 2>/dev/null || true

echo "macOS settings configured!"
echo "NOTE: Some settings (like 'Displays have separate Spaces') require logout to take effect."
