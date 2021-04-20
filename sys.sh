#!/data/data/com.termux/files/usr/bin/bash

function safe_bind_mount()
{
    src=$1
    dst=$2

    printf "mounting $src to $dst\n"
    if [[ ! -d $src ]]; then
        printf "\terror: source dir $src does not exist, skipping\n"
        return
    fi
    if [[ ! -d $dst ]]; then
        printf "\tinfo: destination dir $dst does not exist, creating\n"
        mkdir -p $dst
        printf "\tdone\n"
    fi

    if [[ $(mountpoint -q $dst) ]]; then
        printf "\twarn: distination dir $dst is already mounted, skipping\n"
    else
        mount --bind $src $dst
        printf "\tmounted\n"
    fi
}

function sys_start()
{
    if [[ $# != 0 ]]; then
        chroot=$1
    else 
        chroot="chroot"
    fi
    #cd $(dirname $0)
    # unset LD_PRELOAD in case termux-exec is installed
    unset LD_PRELOAD

    safe_bind_mount /dev/ $(pwd)/root-fs/dev
    safe_bind_mount /proc/ $(pwd)/root-fs/proc
    safe_bind_mount /sys $(pwd)/root-fs/sys
    safe_bind_mount /storage/emulated/0/ $(pwd)/root-fs/root/Storage
    safe_bind_mount /storage/emulated/0/Download $(pwd)/root-fs/root/Downloads
    safe_bind_mount /storage/emulated/0/Pictures $(pwd)/root-fs/root/Pictures
    safe_bind_mount ./root-fs "$(pwd)/root-fs$(pwd)/root-fs"
    safe_bind_mount /data/data/com.termux/files/home/uoa $(pwd)/root-fs/root/uoa
    safe_bind_mount /system/bin $(pwd)/root-fs/system/bin
    safe_bind_mount /system/xbin $(pwd)/root-fs/system/xbin
    safe_bind_mount /sbin $(pwd)/root-fs/system/sbin

    ## uncomment the following line to have access to the home directory of termux
    #command+=" -b /data/data/com.termux/files/home:/root"
    ## uncomment the following line to mount /sdcard directly to /
    #command+=" -b /sdcard"
    command="$chroot $(pwd)/root-fs "
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

function sys_start_lxc()
{
    unset LD_PRELOAD
    chroot='chroot'

    safe_bind_mount /dev ./root-fs/dev
    safe_bind_mount /sys ./root-fs/sys

    safe_bind_mount /storage/emulated/0/ ./root-fs/root/Storage
    safe_bind_mount /storage/emulated/0/Download ./root-fs/root/Downloads
    safe_bind_mount /storage/emulated/0/Pictures ./root-fs/root/Pictures
    safe_bind_mount ./root-fs "./root-fs$(pwd)/root-fs"
    safe_bind_mount /data/data/com.termux/files/home/uoa ./root-fs/root/uoa
    safe_bind_mount /system/bin ./root-fs/system/bin
    safe_bind_mount /system/xbin ./root-fs/system/xbin
    safe_bind_mount /sbin ./root-fs/system/sbin

    ## uncomment the following line to have access to the home directory of termux
    #command+=" -b /data/data/com.termux/files/home:/root"
    ## uncomment the following line to mount /sdcard directly to /
    #command+=" -b /sdcard"
    command="$chroot ./root-fs "
    command+=" /usr/bin/env -i"
    command+=" HOME=/root"
    command+=" USER=root"
    command+=" PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games"
    command+=" TERM=$TERM"
    command+=" LANG=C.UTF-8"
#    command+=" /bin/bash "
   command+=" /bin/bash /root/uoa/unshare.sh"
    com="$@"
    if [ -z "$1" ];then
        exec $command
    else
        $command -c "$com"
    fi
    echo "sleep 5 seconds"
    sleep 5
}

function sys_stop()
{
    umount $(pwd)/root-fs/system/xbin
    umount $(pwd)/root-fs/system/bin
    umount $(pwd)/root-fs/system/sbin
    umount $(pwd)/root-fs/proc
    umount $(pwd)/root-fs/sys
    umount $(pwd)/root-fs/dev/pts
    umount $(pwd)/root-fs/$(pwd)/root-fs
    umount $(pwd)/root-fs/root/uoa
    umount $(pwd)/root-fs/dev
    umount $(pwd)/root-fs/root/Storage
    umount $(pwd)/root-fs/root/Downloads
    umount $(pwd)/root-fs/root/Pictures
}

