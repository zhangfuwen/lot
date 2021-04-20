#!/usr/bin/bash
function vnc_setup()
{
    if [[ -d ~/.vnc ]]; then
        echo ~/.vnc exists
    else
        mkdir ~/.vnc
    fi

    cat > ~/.vnc/xstartup << EOFF
#!/bin/sh
xrdb $HOME/.Xresources
xsetroot -solid grey
export XKL_XMODMAP_DISABLE=1
/etc/X11/Xsession
EOFF


    PS3="select a session: "

    select sess in lxde xfce
    do
        echo "reply number: $REPLY"
        echo "Selected: $sess"
        if [[ $sess == lxde ]];then
            echo "lxsession &" >> ~/.vnc/xstartup
        break;
        fi
        if [[ $sess == xfce ]];then
            echo "xfce4-session &" >> ~/.vnc/xstartup
        break;
        fi
    done
}

function vnc_start()
{
    vncserver -geometry 1900x980
}

function vnc_stop()
{
    id=$1

    vncserver -kill :$1 > /dev/null 2>&1
    [[ -e /tmp/.X$1-lock ]] && rm -rf /tmp/.X$1-lock
    [[ -e /tmp/.X11-unix/X$1 ]] && rm -rf /tmp/.X11-unix/X$1
}


