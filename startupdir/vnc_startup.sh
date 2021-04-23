#!/bin/bash

set -e

source $HOME/.bashrc

## resolve_vnc_connection
VNC_IP=$(hostname -i)

## vnc password
echo -e "\n### VNC password\n"
mkdir -p "$HOME/.vnc"
PASSWD_PATH="$HOME/.vnc/passwd"

if [[ -f $PASSWD_PATH ]]; then
    echo -e "\n### remove existing VNC passwords"
    rm -f $PASSWD_PATH
fi

echo "$VNC_PW" | vncpasswd -f >> $PASSWD_PATH
chmod 600 $PASSWD_PATH


## start vncserver and noVNC webclient
echo -e "\n### start noVNC \n" 
if [[ $DEBUG == true ]]; then echo "$NO_VNC_HOME/utils/launch.sh --vnc localhost:$VNC_PORT --listen $NO_VNC_PORT"; fi
$NO_VNC_HOME/utils/launch.sh --vnc localhost:$VNC_PORT --listen $NO_VNC_PORT &> $STARTUPDIR/no_vnc_startup.log &
PID_SUB=$!

echo -e "\n### start VNC server \n"
echo "remove any old vnc locks"
vncserver -kill $DISPLAY &> $STARTUPDIR/vnc_startup.log \
    || rm -rfv /tmp/.X*-lock /tmp/.X11-unix &> $STARTUPDIR/vnc_startup.log \
    || echo "no existing VNC locks"

echo -e "### start vncserver with param:
      VNC_COL_DEPTH=$VNC_COL_DEPTH
      VNC_RESOLUTION=$VNC_RESOLUTION
      "

vncserver $DISPLAY -depth $VNC_COL_DEPTH -geometry $VNC_RESOLUTION &> $STARTUPDIR/no_vnc_startup.log
echo -e "\n### start window manager...\n"
$HOME/wm_startup.sh 

## log connect options
echo -e "\n###  VNC environment started"
echo -e "\nVNCSERVER started on DISPLAY= $DISPLAY 
           connect via VNC viewer with $VNC_IP:$VNC_PORT
	"
echo -e "\nnoVNC HTML client started:\n
           connect via http://$VNC_IP:$NO_VNC_PORT/?password=...\n"


# Environment Modules
if [ -f /usr/share/Modules/init/.modulespath ] ; then
  echo $EnvironmentModules >> /usr/share/Modules/init/.modulespath
fi
echo "export MODULEPATH=$EnvironmentModules:\$MODULEPATH" >> ${HOME}/.bashrc

if [ -z "$1" ] ; then
    wait $PID_SUB
else
#    echo -e "\n# Execute supplied command\n"
#    echo "Executing supplied command: '$@'"
    exec "/bin/bash"
fi

