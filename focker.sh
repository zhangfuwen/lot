#!/usr/bin/bash

function sum_string()
{
    str=$1
    echo $str | md5sum | awk '{print $1}'
}

function help()
{
    echo '
Usage:
    init img_name   initializes an image
    run img_name    create new container and run bash from an image

    exec img_name command
                    exec command in a running container, 
                    in focker container and image has the same name
                    and this could be only one container for an image
                    to run multiple instances of an image, just `image fork` another image

    remove img_name remove an image, data are still there, use `prune`(not implemented yet)
    image ls        list all images

    image log img_name
                    list image commit history
    '
}


function get_dir_list()
{
    local config_name=$1
    local config_file=configs/$config_name
    if [[ $# -ge 2 ]]; then
        local hash=$2
    fi

    hash_str=$(cat $config_file | awk '{print $1}')
    declare -a hash_list
    for s in $hash_str; do
        if [[ $s != "" ]];then
            hash_list+=($s)
        fi
    done

    dir_str=$(cat $config_file | awk '{print $2}')
    declare -a dir_list
    for s in $dir_str; do
        if [[ $s != "" ]];then
            dir_list+=($s)
        fi
    done
    out=""
    for index in ${!hash_list[@]}; do
        if [[ ${dir_list[$index]} == "" ]]; then
            continue
        fi
        dir=${dir_list[$index]}
        test -L $dir && dir=$(readlink $dir)
        if [[ $out != "" ]]; then
            out=$dir:$out
        else 
            out=$dir
        fi
        if [[ ${hash_list[$index]} == $hash ]];then
            echo $out
            return 0
        fi
    done
    echo $out
    return 0
}

function init()
{
    if [[ $# == 0 ]] || [[ $1 == "help" ]]; then
        echo "focker init config_name"
        return 0
    fi
    test -d configs || mkdir configs
    test -d layers || mkdir layers

    config_name=$1

    if [[ $# == 0 ]]; then
        config_file=configs/focker
    else 
        config_file=configs/$1
    fi

    if [[ -f $config_file ]]; then
        echo "config file:configs/$config_file exists, please use a aother one, or focker remove $config_file"
        return 0
    fi

    uuid=$(uuidgen)
    hash=$(sum_string $uuid)
    echo "$hash layers/$uuid debootstrap" > $config_file
    if [[ -d layers/root-fs ]]; then
        echo "layers/root-fs exists, using it as cache"
    else 
        sudo qemu-debootstrap --arch=arm64 buster layers/root-fs http://ftp.debian.org/debian
    fi
    ln -s layers/root-fs layers/$uuid
    echo "done"
    cat $config_file
}

function remove()
{
    if [[ $# == 0 ]]; then
        config_file=configs/focker
    else 
        config_file=configs/$1
    fi

    rm $config_file
}

# prune to be implemented

function run()
{
    test -d run || mkdir run

    local config_name=$1
    if [[ $# -ge 2 ]];then
        local dst_hash=$2
        lower_dirs=$(get_dir_list $config_name $dst_hash)
    else 
        lower_dirs=$(get_dir_list $config_name)
    fi

    uuid=$(uuidgen)
    hash=$(sum_string $uuid)
    upper=layers/$uuid
    merged=run/merged_$config_name
    work=run/work_$config_name
    set -x
    mkdir $upper $work $merged 

    sudo mount -t overlay -o lowerdir=$lower_dirs,upperdir=$upper,workdir=$work overlay $merged
    set +x
    sudo mount -o rbind /dev/ $merged/dev
    sudo mount --make-rslave $merged/dev
    sudo chroot $merged unshare -p -f qemu-aarch64-static /usr/bin/bash

    sudo umount -l $merged/dev
    sudo umount -l $merged/proc
    sudo umount -l $merged

    PS3="$hash layers/$uuid created, do you want to remove/commit it?"
    select character in "remove it" "commit it"
    do
        echo "Selected operation: $character"
        if [[ $character = "remove it" ]]; then
            sudo rm -rf $upper
            break
        elif [[ $character = "commit it" ]]; then
            printf "please enter one line commit msg:"
            IFS= read -r commit_msg
            echo "$hash $upper $commit_msg" >> configs/$config_name
            break
        fi 
    done
    sudo rm -rf $merged
    sudo rm -rf $work
}


function image()
{
    if [[ $# == 1 ]] && [[ $1 == 'help' ]]; then
        image_usage
        return 0
    fi
    if [[ $# == 1 ]] && [[ $1 == 'ls' ]]; then
        (cd configs; ls -la)
    fi
    if [[ $# == 2 ]] && [[ $1 == 'log' ]]; then
        local img=$2
        (cat configs/$img)
    fi
    if [[ $1 == 'fork' ]]; then
        if [[ $# -lt 3 ]]; then
            image_usage
            return 1
        fi
        local img=$2
        local hash=$3
        if [[ $# -eq 4 ]];then
            local new_name=$4
        else 
            printf "please enter new image name:"
            IFS=' ' read -r new_name
        fi
        (image_fork $img $hash $new_name)
    fi
}
function image_usage()
{
    cat <<EOF
    focker image ls
    focker image log
    focker image fork config_name hash [ new_config_name]
EOF

}

function image_fork()
{
    local img=$1
    local hash=$2
    local new_name=$3

    local found_hash=0
    while read line
    do
        local tmp_hash=$(echo $line | awk '{print $1}')
        echo $line >> configs/$new_name
        if [[ $tmp_hash == $hash ]]; then
            found_hash=1
            break
        fi
    done < configs/$img

    if [[ $found_hash == 0 ]];then
        echo "error, no hash:$hash found in configs/$img"
        echo "new img:$new_name created but may end up with errors"
    else 
        echo "new img:$new_name created"
    fi
}

function exec()
{
    local name=$1
    local cmd=$2
    # name to pid
    local pid=$(pgrep -P $(pgrep -P $(pgrep -P $(pgrep -f ".*run $name"))))
    if [[ $pid == "" ]]; then
        echo "failed to find pid for name $name"
        return -1
    fi
    sudo nsenter -at $pid $cmd
}



if [[ $# != 0 ]];then
    function=$1
    if ! (type $function 2>/dev/null | grep "shell function");then
        help
        exit -1
    fi
    if [[ $# != 0 ]]; then
        shift
        if ! $function "$@"; then
            help
        fi
    else
        if ! $function; then
            help
        fi
    fi
fi
set +x
