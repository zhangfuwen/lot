#!/system/bin/sh
cur_shell=$(basename $(readlink /proc/$$/exe))

if [[ $cur_shell == "bash" ]]; then
    script_dir=$(dirname $(realpath $BASH_SOURCE))
else
    script_dir=$(dirname $(realpath $_))
fi
source $script_dir/lib.sh

log_level=$log_level_debug
log_d "cur_shell $cur_shell"
log_d "script_dir $script_dir"

function is_not_mountpoint()
{
    dir=$1
    if mountpoint $dir 2>&1 | grep "is not a mountpoint" > /dev/null; then
        return 0
    fi
    return 1
}

function has_bad_mount()
{
    mountpoint_dir=$1
    if mountpoint $mountpoint_dir 2>&1 | grep "Transport"; then
        return 0;
    else
        return 1;
    fi
}

function has_good_mount()
{
    mountpoint_dir=$1
    if mountpoint -q $mountpoint_dir; then
        return 0;
    else
        return 1;
    fi
}

function safe_umount()
{
    dir=$1
    printf "umount $dir... "
    if has_bad_mount $dir; then
	if /sbin/busybox umount -l $dir; then
            printf "$(style green 'umounted bad mountpoint')\n"
        else
	    errno=$?
	    printf "$(style red 'failed to umount bad mountpoint,%d')\n" $errno
	    return $errno
	fi
    fi

    if [[ ! -d $dir ]]; then
	printf "$(style red 'error, not a dir')\n"
	return 1
    fi

    if is_not_mountpoint $dir; then
        printf "$(style red 'is not mountpoint, skipping')\n"
	return 0
    fi

    if has_good_mount $dir; then
	if /sbin/busybox umount -l $dir; then
            printf "$(style green 'umounted')\n"
	    return 0
        else
	    errno=$?
	    printf "$(style red 'failed to umount %d')\n" $errno
	    return $errno
	fi
    fi

    if has_bad_mount $dir; then
	if /sbin/busybox umount -l $dir; then
            printf "$(style green 'umounted bad mountpoint')\n"
        else
	    errno=$?
	    printf "$(style red 'failed to umount bad mountpoint,%d')\n" $errno
	    return $errno
	fi
    fi

    printf "$(style red 'unknown error, do know what happenedd.')\n"

}

function safe_bind_mount()
{
    src=$1
    dst=$2

    if has_good_mount $dst || has_bad_mount $dst; then
	    safe_umount $dst
    fi

    printf "mounting $src to $dst..."
    if [[ ! -d $src ]]; then
        printf "\terror: source dir $src does not exist, skipping\n"
        return
    fi
    if [[ ! -d $dst ]]; then
        printf "\tinfo: destination dir $dst does not exist, creating\n"
        mkdir -p $dst
	printf "\t$(style green 'done')\n"
    fi

    mount --bind $src $dst
    printf "\t$(style green 'done')\n"
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

function bind_dev()
{
    /sbin/busybox mount -o rbind /dev/ ./root-fs/dev
    /sbin/busybox mount --make-rslave ./root-fs/dev
}

function unbind_dev()
{
    safe_umount ./root-fs/dev
}

function sys_start_lxc()
{
    unset LD_PRELOAD
    chroot='chroot'

    bind_dev
    safe_bind_mount /sys ./root-fs/sys

    safe_bind_mount /storage/emulated/0/ ./root-fs/root/Storage
    safe_bind_mount /storage/emulated/0/Download ./root-fs/root/Downloads
    safe_bind_mount /storage/emulated/0/Pictures ./root-fs/root/Pictures
    safe_bind_mount /data/data/com.termux/files/home/uoa ./root-fs/root/uoa
    safe_bind_mount /system/bin ./root-fs/system/bin
    safe_bind_mount /system/xbin ./root-fs/system/xbin
    safe_bind_mount /sbin ./root-fs/system/sbin

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
    local rootfs_dir=$(realpath ./)
    if [[ $# != 0 ]];then
        rootfs_dir=$(realpath $1)
    fi
    log_i "stopping container at %s" $rootfs_dir
    cd $rootfs_dir
    safe_umount ./root-fs/system/xbin
    safe_umount ./root-fs/system/bin
    safe_umount ./root-fs/system/sbin
    safe_umount ./root-fs/sys
    safe_umount ./root-fs/proc
    safe_umount ./root-fs/root/uoa
    # mountpoint command is not reliable on root-fs/root/uoa, it always gives a wrong result
    /sbin/busybox umount -l ./root-fs/root/uoa
    safe_umount ./root-fs/root/Storage
    safe_umount ./root-fs/root/Downloads
    safe_umount ./root-fs/root/Pictures
    safe_umount ./root-fs/root/.gvfs
    unbind_dev
    cd - > /dev/null
    echo "1" > $script_dir/pipe1 &
    last_pid=$!
    sleep 2
    ps --pid $last_pid &>/dev/null && kill -9 $last_pid
    echo "system total mount items:$(mount | wc | awk '{print $1}')"

}

if [[ $# == 2 ]] && [[ $1 == 'stop' ]]; then
    rootfs_dir=$2
    sys_stop $rootfs_dir
fi
