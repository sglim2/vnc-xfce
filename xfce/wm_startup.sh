#!/usr/bin/env bash

set -e

echo -e "\n### start XFCE Window Manager\n"


/usr/bin/startxfce4 --replace > $HOME/wm.log &
sleep 1
cat $HOME/wm.log

### best disable screensaver/power management
#xset -dpms &
xset s noblank &
xset s off &
