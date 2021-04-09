#!/bin/bash

vscode_url="http://10.227.82.171:3000/linux_on_tnt/code_1.55.0-1617120113_arm64.deb"
wps_url="http://10.227.82.171:3000/linux_on_tnt/wps-office_11.1.0.10161_arm64.deb"
yozo_url="http://10.227.82.171:3000/linux_on_tnt/yozo-office_8.0.2720.191ZH.S1_arm64.deb"

if [[ ! $(type log_i &>/dev/null) ]]; then
    my_log=echo
else
    my_log=log_i
fi

function install_qtcreator()
{
    apt-get install qt5-default qt5-doc qtbase5-examples qtbase5-doc-html qtcreator build-essential qtbase5-dev qtbase5-gles-dev
}

function install_ime()
{
    $SUDO apt install fcitx fcitx-table-wbpy
    cat >> ~/.xprofile << EOF
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export SDL_IM_MODULE=fcitx
EOF
    cat ~/.xprofile >> ~/.bashrc
    source ~/.bashrc

    echo "fcitx &" >> ~/.vnc/xstartup

}

function install_nettools()
{
    $SUDO apt-get install -y iputils-ping iproute2
    alias ifconfig='ip -c a'
    echo "alias ifconfig='ip -c a'" >> ~/.bashrc
}

function install_lxde()
{
    $SUDO apt-get install -y lxde
}

function install_xfce()
{
    $SUDO apt-get install -y xfce
}

function install_from_mirror()
{
    local pkg_name=$1
    $my_log "installing $pkg_name"
    $SUDO dpkg -l $pkg_name &>/dev/null || $SUDO apt-get -qq install -y $pkg_name
}

function install_deb_from_url()
{
    local url=$1
    $my_log "installing from $url"
    if [[ ! $(command -v wget) ]]; then
        "echo wget is not installed, installing"
        $SUDO apt-get install -y wget apt 
    fi
    UUID=$(cat /proc/sys/kernel/random/uuid)
    wget -O /tmp/$UUID.deb $url
    $SUDO dpkg -i /tmp/$UUID.deb
}

function install_wps()
{
    $SUDO dpkg -l wps-office &>/dev/null || install_deb_from_url $wps_url
}

function install_yozo()
{
    $SUDO dpkg -l yozo-office &>/dev/null || install_deb_from_url $yozo_url
}

function install_vscode()
{
    $SUDO dpkg -l code &>/dev/null || install_deb_from_url $vscode_url
}

function install_firefox()
{
    install_from_mirror "firefox-esr"
}

function install_all()
{
    list="wps
    yozo
    vscode"
    for sw in $list; do
        install_$sw
    done

    list="tightvncserver lxde firefox-esr"
    for sw in $list; do
        install_from_mirror $sw
    done

}
