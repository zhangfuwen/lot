#!/usr/bin/env -i bash
dir=$(dirname $0)

source $dir/vnc.sh
vnc_stop 1
tightvncserver
echo "waiting"
cat /root/uoa/pipe1 
