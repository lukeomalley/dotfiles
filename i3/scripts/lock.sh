#!/bin/bash

rm /tmp/i3lock.png
img=/tmp/i3lock.png

scrot $img
convert $img -blur 0x8 -scale 10% -scale 1000% $img

i3lock -u -i $img
