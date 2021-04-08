#!bin/bash
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

    vncserver -kill :$1
    rm -rf /tmp/.X$1-lock
    rm -rf /tmp/.X11-unix/X$1
}


op=nothing

# no opts
if [[ $# == 0 ]]; then
    PS3="command: "
    select op in start, stop, setup, nothing 
    do
        break
    done
fi

# has opts
case $1 in
    start ) op=start;;
    stop ) 
        op=stop
        id=$2
        ;;
    setup ) op=setup;;
    *)  op=nothing;;
esac


echo "Selected command: $op"
echo "Selected number: $REPLY"

if [[ "$op" = "start" ]]; then
    vnc_start
    exit 0
fi    
if [[ "$op" = "stop" ]]; then
    vnc_stop $id
    exit 0
fi    

if [[ "$op" = "setup" ]]; then
    vnc_setup
    exit 0
fi    
exit 0
