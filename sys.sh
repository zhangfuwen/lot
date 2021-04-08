#!/data/data/com.termux/files/usr/bin/bash

function sys_start()
{
    cd $(dirname $0)
    # unset LD_PRELOAD in case termux-exec is installed
    unset LD_PRELOAD
    #mount -t dev /dev root-fs/dev
    mount --rbind /dev/ root-fs/dev
    mount --bind /proc/ root-fs/proc
    mount --bind /sys root-fs/sys

    mount --bind /storage/emulated/0/ root-fs/root/Storage
    mount --bind /storage/emulated/0/Download root-fs/root/Download
    mount --bind /storage/emulated/0/Pictures root-fs/root/Pictures
    #mount --bind root-fs/root /dev/shm

    # because some sym links uses this path
    set -x
    mkdir -p "root-fs$(pwd)"
    mount --bind $(pwd) "root-fs$(pwd)"
    mount --bind /data/data/com.termux/files/home/uao root-fs/root/uoa

    mkdir -p "root-fs/system/xbin"
    mkdir -p "root-fs/system/sbin"
    mkdir -p "root-fs/system/bin"
    mount --bind /system/bin root-fs/system/bin
    mount --bind /system/xbin root-fs/system/xbin
    mount --bind /sbin root-fs/system/sbin
    set +x


    ## uncomment the following line to have access to the home directory of termux
    #command+=" -b /data/data/com.termux/files/home:/root"
    ## uncomment the following line to mount /sdcard directly to /
    #command+=" -b /sdcard"
    command="chroot ./root-fs "
    command+=" /usr/bin/env -i"
    command+=" HOME=/root"
    command+=" PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games"
    command+=" TERM=$TERM"
    command+=" LANG=C.UTF-8"
    command+=" /bin/bash --login"
    com="$@"
    if [ -z "$1" ];then
        exec $command
    else
        $command -c "$com"
    fi
}

funcion sys_stop()
{
    umount root-fs/system/xbin
    umount root-fs/system/bin
    umount root-fs/system/sbin
    umount root-fs/proc
    umount root-fs/sys
    umount root-fs/dev/pts
    umount root-fs/$(pwd)
    umount root-fs/root/uoa
    umount root-fs/dev
}

op=nothing


# no opts
if [[ $# == 0 ]]; then
    PS3="command: "
    select op in start, stop, nothing 
    do
        break
    done
fi

# has opts
case $1 in
start ) op=start;;
stop ) op=stop;;
*) ;;
esac


echo "Selected command: $op"
echo "Selected number: $REPLY"

if [[ $op = "start" ]]; then
    sys_start
    exit 0
fi    
if [[ $op = "stop" ]]; then
    sys_stop
    exit 0
fi    
exit 0
