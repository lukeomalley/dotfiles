xrdb -merge ~/.config/X11/.Xresources
urxvtd -o -q -f

xcompmgr &
devilspie -a &

xset r rate 200 50
setxkbmap -option caps:escape

exec i3
