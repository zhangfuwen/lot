source ./focker.sh
expect="3262a8aac980b33fb82c0c8c71d2c3b5" 
out=$(sum_string "36b78588-a2a1-11eb-87b4-e4b97aed9eb0")
if [[ $out != $expect ]]; then
    echo "sum_string failed, out:$out, expect:$expect"
    type sum_string
fi

# get_dir_list
function test_get_dir_list()
{
    config_name=focker_ut
    config_file=configs/focker_ut
    test -f $config_file && rm $config_file
    dst_hash=""
    for idx in $(seq 1 5); do
        local uuid=$(uuidgen)
        local hash=$(sum_string $uuid)
        local msg="commit #$idx"
        if [[ $idx == 3 ]]; then
            dst_hash=$hash
        fi
        echo "$hash $uuid $msg" >> $config_file
    done

    out=$(get_dir_list $config_name $dst_hash)
    count=$(echo "${out}" | awk -F":" '{print NF-1}')
    rm $config_file
    if [[ $count != 2 ]]; then
        echo "get_dir_list error $out"
    fi
}

test_get_dir_list
