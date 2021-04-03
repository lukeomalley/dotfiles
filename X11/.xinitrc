xrdb -merge ~/.config/X11/.Xresources
urxvtd -o -q -f

xcompmgr &
devilspie -a &

xset r rate 200 50

udiskie &

xmodmap ~/.config/X11/.Xmodmap
setxkbmap -option caps:escape

xmodmap -e "keycode 49 = Escape"
xmodmap -e "keycode 9 = grave asciitilde"

exec i3
