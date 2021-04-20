#!/usr/bin/env -i bash
dir=$(dirname $0)
umount /dev/pts
mount -t devpts devpts /dev/pts
mount -t proc proc /proc

source $dir/vnc.sh
vnc_stop 1
tightvncserver
echo "waiting"
cat /root/uoa/pipe1 
