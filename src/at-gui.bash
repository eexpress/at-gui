#!/bin/bash

# ROCKPNG不设置，将缺省使用"/usr/share/icons/gnome/256x256/apps/gnome-help.png"来显示屏幕提醒。
if [ -f "/usr/share/pixmaps/at-gui.png" ]; then
ROCKPNG="/usr/share/pixmaps/at-gui.png"
fi

export DISPLAY=:0.0

if [ $# == 1 ] ; then	# 一个参数，使用延时几分钟的格式。
echo "export DISPLAY=:0.0 && /usr/bin/rockpng $ROCKPNG" |\at "now + $1 minutes"
notify-send -i alarm-symbolic "Remind in $1 minutes"
fi

if [ $# == 2 ] ; then	# 两个参数，使用定时几点几分的格式。
echo "export DISPLAY=:0.0 && /usr/bin/rockpng $ROCKPNG" |\at "$1:$2"
notify-send -i alarm-symbolic "Remind at $1:$2"
fi
