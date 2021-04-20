#!/usr/bin/env -i bash
dir=$(dirname $0)
mount -t proc proc /proc

source $dir/vnc.sh
vnc_stop 1
tightvncserver
hide_output=$(cat /root/uoa/pipe1) # wait for signal to quit namespace
hide_output=$([[ -d /proc ]] && mountpoint -q /proc && umount -l /proc 2>&1) # umount /proc, maybe umounted by somewhere else

