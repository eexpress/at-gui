#!/bin/bash

# ROCKPNG不设置，将缺省使用"/usr/share/icons/gnome/256x256/apps/gnome-help.png"来显示屏幕提醒。
HOMEPNG="$HOME/.local/share/at-gui.png"
APPPNG="/usr/share/pixmaps/at-gui.png"

if [ -f $HOMEPNG ]; then ROCKPNG=$HOMEPNG
elif [ -f $APPPNG ]; then ROCKPNG=$APPPNG
fi

EXEC="export DISPLAY=$DISPLAY && /usr/bin/rockpng $ROCKPNG"

if [ $# == 1 ] ; then	# 一个参数，使用延时几分钟的格式。
echo  $EXEC|\at "now + $1 minutes"
notify-send -i alarm-symbolic "Remind in $1 minutes"
fi

if [ $# == 2 ] ; then	# 两个参数，使用定时几点几分的格式。
echo $EXEC |\at "$1:$2"
notify-send -i alarm-symbolic "Remind at $1:$2"
fi
