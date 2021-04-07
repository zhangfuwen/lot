id=$1

vncserver -kill :$1
rm -rf /tmp/.X$1-lock
rm -rf /tmp/.X11-unix/X$1
