#!/bin/bash

#~ 可以设置 at-gui 右键选择时，弹出图片选择界面。
#~ zenity 指定不了目录。
#~ cd /usr/share/icons/gnome/256x256/apps/
#~ 取消选择PNG图片，将使用缺省的提醒图片。也可以注释掉下面zenity这行。
#~ ROCKPNG=`zenity --file-selection --file-filter='*.png'`
echo "export DISPLAY=:0.0 && /usr/bin/rockpng $ROCKPNG" |\at "now + $1 minutes"
