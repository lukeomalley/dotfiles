#!/bin/bash

# =============================================================================
# General Scripts
# =============================================================================

compress() {
  tar cvzf $1.tar.gz $1
}

wp () {
  rm "$DOTFILES/i3/feh/wallpaper.jpg"
  cp $1 "$DOTFILES/i3/feh/wallpaper.jpg"
  feh --bg-scale ~/.config/i3/feh/wallpaper.jpg
}

dualmon() {
  xrandr \
      --output eDP-1 --mode 2560x1440 --scale '0.5x0.5' \
      --output DP-1 --mode 1920x1080 --scale 2x2
}

singlemon() {
  xrandr \
      --output eDP-1 --mode 2560x1440 \
      --output DP-1 --off
}

# =============================================================================
# Git Scripts/Aliases
# =============================================================================

gop () {
  git remote -v \
    | awk '/origin.*push/ {print $2}' \
    | sed "s/git@github.com:/github.com\//g" \
    | sed "s/.git//g" \
    | xargs brave
}

gdiff() {
  git diff main..$(git branch --show-current)
}

