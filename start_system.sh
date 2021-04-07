#!/data/data/com.termux/files/usr/bin/bash
cd $(dirname $0)
# unset LD_PRELOAD in case termux-exec is installed
unset LD_PRELOAD
#mount -t dev /dev root-fs/dev
mount -t sysfs /sys root-fs/sys
mount -t proc /proc root-fs/proc
mount --rbind /dev root-fs/dev

mount --bind /storage/emulated/0/ root-fs/root/Storage
#mount --bind root-fs/root /dev/shm

# because some sym links uses this path
set -x
mkdir -p "root-fs$(pwd)"
mount --bind $(pwd) "root-fs$(pwd)"

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
