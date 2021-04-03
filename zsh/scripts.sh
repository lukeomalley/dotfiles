#!/bin/bash

compress() {
  tar cvzf $1.tar.gz $1
}


gop () {
  git remote -v | awk '/origin.*push/ {print $2}' | sed "s/git@github.com:/github.com\//g" | xargs firefox-developer-edition
}

wp () {
  rm "$DOTFILES/i3/feh/wallpaper.jpg"
  cp $1 "$DOTFILES/i3/feh/wallpaper.jpg"
  feh --bg-scale ~/.config/i3/feh/wallpaper.jpg
}

