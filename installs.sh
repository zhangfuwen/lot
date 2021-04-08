#!/bin/bash
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
    $SUDO apt-get install iputils-ping iproute2
    alias ifconfig='ip -c a'
    echo "alias ifconfig='ip -c a'" >> ~/.bashrc
}
