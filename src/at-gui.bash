#!/bin/bash

# ROCKPNG不设置，将缺省使用"/usr/share/icons/gnome/256x256/apps/gnome-help.png"来显示屏幕提醒。

if [ $# == 1 ] ; then	# 一个参数，使用延时几分钟的格式。
echo "export DISPLAY=:0.0 && /usr/bin/rockpng $ROCKPNG" |\at "now + $1 minutes"
fi

if [ $# == 2 ] ; then	# 两个参数，使用定时几点几分的格式。
echo "export DISPLAY=:0.0 && /usr/bin/rockpng $ROCKPNG" |\at "$1:$2"
fi
