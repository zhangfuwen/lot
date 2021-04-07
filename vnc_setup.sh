if [[ -d ~/.vnc ]]; then
    echo ~/.vnc exists
else
    mkdir ~/.vnc
fi

cat > ~/.vnc/xstartup << EOF
#!/bin/sh

xrdb $HOME/.Xresources
xsetroot -solid grey
export XKL_XMODMAP_DISABLE=1
/etc/X11/Xsession

EOF 


PS3="select a session: "

select sess in lxde xfce
do
    echo "reply number: $REPLY"
    echo "Selected: $sess"
    if [[ $sess == lxde ]];then
        echo "lxsession &" >> ~/.vnc/xstartup
    fi
    if [[ $sess == xfce ]];then
        echo "xfce4-session &" >> ~/.vnc/xstartup
    fi
done
