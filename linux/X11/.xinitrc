# Merge Xresources
xrdb -merge ~/.config/X11/.Xresources

# Start urxvt daemon
urxvtd -o -q -f

# Disable hardware beep
xset -b

# Start xcompmgr to set window transparency
xcompmgr &
devilspie -a &

# Start udiskie to look for usb devices
udiskie &

# Adjust keyboard settings
setxkbmap -option caps:escape
xset r rate 200 50

# Adjust mouse sensitivity
xinput set-prop "Logitech Gaming Mouse G502" "Coordinate Transformation Matrix" 0.6 0 0 0 0.6 0 0 0 1
xinput set-prop "MX Master 2S Mouse" "Coordinate Transformation Matrix" 0.6 0 0 0 0.6 0 0 0 1
 
# Start i3
exec i3
