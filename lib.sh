sec_seq='\033['
seq_end='m'

normal="0"

reset_bold="21"
reset_ul="24"

bold="1"
dim="2"
italic="3"
underline="4"
blink="5"
inverted="7"
strikethrough="9"

# Foreground colours
black="30"
red="31"
green="32"
yellow="33"
blue="34"
magenta="35"
cyan="36"
white="37"
# bright
br_black="90"
br_red="91"
br_green="92"
br_yello="93"
br_blue="94"
br_magenta="95"
br_cyan="96"
br_white="97"

# Background colours (optional)
bg_black="40"
bg_red="41"
bg_green="42"
bg_yellow="43"
bg_blue="44"
bg_magenta="45"
bg_cyan="46"
bg_white="47"
# light
bg_br_black="100"
bg_br_red="101"
bg_br_green="102"
bg_br_yello="103"
bg_br_blue="104"
bg_br_magenta="105"
bg_br_cyan="106"
bg_br_white="107"

function ddref()
{ 
   eval "CURRENT=\$$1"
   echo $CURRENT
}

function set_style() {
    if [[ $# == 5 ]]; then
        printf "${sec_seq}$(ddref $1);$(ddref $2);$(ddref $3);$(ddref $4);$(ddref $5)${seq_end}"
    elif [[ $# == 4 ]]; then # fg, bg, font
        printf "${sec_seq}$(ddref $1);$(ddref $2);$(ddref $3);$(ddref $4)${seq_end}"
    elif [[ $# == 3 ]]; then # two functions
        printf "${sec_seq}$(ddref $1);$(ddref $2);$(ddref $3)${seq_end}"
    elif [[ $# == 2 ]]; then
        printf "${sec_seq}$(ddref $1);$(ddref $2)${seq_end}"
    elif [[ $# == 1 ]]; then
        printf "${sec_seq}$(ddref $1)${seq_end}" 
    fi
}

function style() {
    if [[ $# == 5 ]]; then
        printf "${sec_seq}$(ddref $1);$(ddref $2);$(ddref $3);$(ddref $4)${seq_end}${5}${sec_seq}${normal}${seq_end}"
    elif [[ $# == 4 ]]; then # fg, bg, font
        printf "${sec_seq}$(ddref $1);$(ddref $2);$(ddref $3)${seq_end}${4}${sec_seq}${normal}${seq_end}"
    elif [[ $# == 3 ]]; then # two functions
        printf "${sec_seq}$(ddref $1);$(ddref $2)${seq_end}${3}${sec_seq}${normal}${seq_end}"
    elif [[ $# == 2 ]]; then
        printf "${sec_seq}$(ddref $1)${seq_end}${2}${sec_seq}${normal}${seq_end}"
    elif [[ $# == 1 ]]; then
        printf $1
    fi
}


function println() {
    if [[ $# == 1 ]];then
        printf "$@\n"
    else
        first=$1
        shift;
        rest="$@"
        printf "$1\n" $rest
    fi
}

log_level=3
log_level_debug=2
log_level_info=3
log_level_warn=4
log_level_error=5
function log_e() {
    if [[ $log_level > $log_level_error ]];then
        return 0;
    fi
    printf "$(style inverted bold 'error:')"
    set_style red bold
    printf "$@"
    set_style normal
    printf "\n"
}

function log_w() {
    if [[ $log_level > $log_level_warn ]];then
        return 0;
    fi
    printf "$(style inverted bold 'warning:')"
    set_style yellow bold
    printf "$@"
    set_style normal
    printf "\n"
}

function log_i() {
    if [[ $log_level > $log_level_info ]];then
        return 0;
    fi
    printf "$(style inverted bold 'info:')"
    set_style br_blue bold
    printf "$@"
    set_style normal
    printf "\n"
}

function log_d() {
    if [[ $log_level > $log_level_debug ]];then
        return 0;
    fi
    printf "$(style inverted bold 'debug:')"
    set_style dim bold
    printf "$@"
    set_style normal
    printf "\n"
}

function user_confirm()
{
    local msg=$1
    while true; do
        read -p "$msg[Yy/Nn]" yn
        case $yn in
            [Yy]* ) return 0; break;;
            [Nn]* ) return 1; break;;
            * ) echo "Please answer yes[Yy] or no[Nn].";;
        esac
    done
}

