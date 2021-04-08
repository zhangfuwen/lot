#!/data/data/com.termux/files/usr/bin/bash

function sys_start()
{
    #cd $(dirname $0)
    # unset LD_PRELOAD in case termux-exec is installed
    unset LD_PRELOAD
    #mount -t dev /dev root-fs/dev
    mount --rbind /dev/ $(pwd)/root-fs/dev
    mount --bind /proc/ $(pwd)/root-fs/proc
    mount --bind /sys $(pwd)/root-fs/sys

    mkdir -p ./root-fs/root/Storage
    mount --bind /storage/emulated/0/ $(pwd)/root-fs/root/Storage
    mount --bind /storage/emulated/0/Download $(pwd)/root-fs/root/Downloads
    mount --bind /storage/emulated/0/Pictures $(pwd)/root-fs/root/Pictures
    #mount --bind root-fs/root /dev/shm

    # because some sym links uses this path
    set -x
    mkdir -p "root-fs$(pwd)"
    mount --bind $(pwd) "root-fs$(pwd)"

    mkdir -p root-fs/root/uoa
    mount --bind /data/data/com.termux/files/home/uoa root-fs/root/uoa

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
    command="chroot $(pwd)/root-fs "
    command+=" /usr/bin/env -i"
    command+=" HOME=/root"
    command+=" USER=root"
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

function sys_stop()
{
    umount $(pwd)/root-fs/system/xbin
    umount $(pwd)/root-fs/system/bin
    umount $(pwd)/root-fs/system/sbin
    umount $(pwd)/root-fs/proc
    umount $(pwd)/root-fs/sys
    umount $(pwd)/root-fs/dev/pts
    umount $(pwd)/root-fs/$(pwd)
    umount $(pwd)/root-fs/root/uoa
    umount $(pwd)/root-fs/dev
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

if [[ "$op" = "start" ]]; then
    sys_start
    exit 0
fi    
if [[ "$op" = "stop" ]]; then
    sys_stop
    exit 0
fi    
exit 0
