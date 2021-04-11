function fix_mounts()
{
    cat >> /etc/fstab << EOF
devpts           /dev/pts              devpts  gid=5,mode=620,newinstance  0 0
sys  /sys sysfs rw,nosuid,nodev,noexec,relatime
EOF
    mount /sys
    mount /dev
    mount /dev/pts
#    mv /usr/sbin/adduser{,.bak}
#    mv /usr/sbin/addgroup{,.bak}
#    mv /usr/sbin/deluser{,.bak}
#    mv /usr/sbin/delgroup{,.bak}
#    ln -s /system/sbin/busybox /usr/sbin/adduser
#    ln -s /system/sbin/busybox /usr/sbin/addgroup
#    ln -s /system/sbin/busybox /usr/sbin/deluser
#    ln -s /system/sbin/busybox /usr/sbin/delgroup
}

function fix_dns()
{
    if [[ -f /etc/resolv.conf ]];then
        prepend_txt="nameserver 10.91.0.1
nameserver 8.8.8.8
nameserver 8.8.4.4"
        original_txt=$(cat /etc/resolv.conf)
        echo "$prepend_txt" > /etc/resolv.conf
        echo "$original_txt" >> /etc/resolv.conf
    else
        cat >> /etc/resolv.conf << EOF
nameserver 10.91.0.1
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF
    fi

}
function fix_apt_users()
{
    /system/sbin/busybox adduser -D -H pulse
    /system/sbin/busybox addgroup lightdm
    /system/sbin/busybox adduser -D -H -S systemd-resolve
    /system/sbin/busybox adduser -D -H -S systemd-timesync
    /system/sbin/busybox adduser -D -H -S geoclue
    /system/sbin/busybox adduser -D -H -S netdev
    /system/sbin/busybox adduser -D -H -S avahi
    /system/sbin/busybox adduser -D -H -S rtkit
    /system/sbin/busybox addgroup netdev
    /system/sbin/busybox adduser -D -H -S systemd-network
    /system/sbin/busybox adduser -D -H -S messagebus
    chmod +s /usr/lib/dbus-1.0/dbus-daemon-launch-helper
    ln -s /etc/init.d/dbus /var/service
    /etc/init.d/dbus start
#    echo 'APT::Sandbox::User "u0_a207";' > /etc/apt/apt.conf.d/90sandbox
}


function fix_users()
{
    /system/sbin/busybox addgroup -g 1011 adb
    /system/sbin/busybox addgroup -g 1015 sdcard_rw
    /system/sbin/busybox addgroup -g 1028 sdcard_r
    /system/sbin/busybox addgroup -g 3001 net_bt_admin
    /system/sbin/busybox addgroup -g 3002 net_bt
    /system/sbin/busybox addgroup -g 3003 inet
    /system/sbin/busybox addgroup -g 3006 net_bw_stats
    /system/sbin/busybox addgroup -g 3009 readproc
    /system/sbin/busybox addgroup -g 3011 uhid
    /system/sbin/busybox addgroup -g 1004 input
    /system/sbin/busybox addgroup -g 1007 log

    /system/sbin/busybox adduser -u 10207 -s /bin/bash u0_a207
#    /system/sbin/busybox adduser -D -H _apt

    /system/sbin/busybox adduser u0_a207 readproc
    /system/sbin/busybox adduser u0_a207 uhid
    /system/sbin/busybox adduser u0_a207 input
    /system/sbin/busybox adduser u0_a207 log
    /system/sbin/busybox adduser u0_a207 inet
    /system/sbin/busybox adduser u0_a207 net_bt
    /system/sbin/busybox adduser u0_a207 net_bt_admin
    /system/sbin/busybox adduser u0_a207 sdcard_rw
    /system/sbin/busybox adduser u0_a207 sdcard_r
    /system/sbin/busybox adduser u0_a207 adb

    /system/sbin/busybox adduser root readproc
    /system/sbin/busybox adduser root uhid
    /system/sbin/busybox adduser root input
    /system/sbin/busybox adduser root log
    /system/sbin/busybox adduser root inet
    /system/sbin/busybox adduser root net_bt
    /system/sbin/busybox adduser root net_bt_admin
    /system/sbin/busybox adduser root sdcard_rw
    /system/sbin/busybox adduser root sdcard_r
    /system/sbin/busybox adduser root adb


# uid=0(root) gid=0(root) groups=0(root),
# 1004(input),
# 1007(log),
# 1011(adb),
# 1015(sdcard_rw),
# 1028(sdcard_r),
# 3001(net_bt_admin),
# 3002(net_bt)
# 3003(inet)
# 3006(net_bw_stats)
# 3009(readproc)
# 3,011(uhid) context=u:r:su:s0
}

function fix_all()
{
    fix_dns
    fix_mounts
    fix_users
}
