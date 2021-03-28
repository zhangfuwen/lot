#!/data/data/com.termux/files/usr/bin/bash
cd $(dirname $0)
# unset LD_PRELOAD in case termux-exec is installed
unset LD_PRELOAD
mount --bind -o ro /dev/ ubuntu-fs/dev
mount --bind /proc/ ubuntu-fs/proc
mount --bind /storage/emulated/0/Download ubuntu-fs/root/Download
mount --bind /storage/emulated/0/Pictures ubuntu-fs/root/Pictures
mount --bind ubuntu-fs/root /dev/shm 

# because some sym links uses this path
mkdir -p ubuntu-fs/data/data/com.termux
mount --bind /data/data/com.termux ubuntu-fs/data/data/com.termux

## uncomment the following line to have access to the home directory of termux
#command+=" -b /data/data/com.termux/files/home:/root"
## uncomment the following line to mount /sdcard directly to / 
#command+=" -b /sdcard"
command="chroot ./ubuntu-fs "
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
