#!/bin/bash

declare -A hosts=(
    ["jump"]="guest   10.175.183.246  12345678 Jump server"
    ["220"]="root   10.175.183.220  12345678 Openstack_server"
    ["30"]="root  10.175.183.30   12345678 instance"
    ["200"]="root     10.175.183.200  12345678 Local_HA_MS_node"
)

#========common functions=========================
function show_keys() {
    printf "\033[1m\033[4m\033[36;40m%-15s\033[0m | \033[1m\033[4m\033[33;40m%-20s\033[0m | \033[1m\033[4m\033[32;40m%s\033[0m\n" "Key" "Ip" "Description" 
    for key in $(echo ${!hosts[*]})
    do
        value=(${hosts[$key]})
        #echo -e "\033[36m$key\033[0m : \033[33m${value[1]}\033[0m : \033[32m${value[3]}\033[0m"
        printf "\033[36m%-15s\033[0m | \033[33m%-20s\033[0m | \033[32m%s\033[0m\n" "$key" "${value[1]}" "${value[3]}"
    done
}

function validate() {
    for key in $(echo ${!hosts[*]})
    do
        if [[ "$key" == "$1" ]]; then
            return 0
        fi
    done
    return 1
}

#==========main===================
validate $1
if [[ $? = 0 ]]; then
    value=(${hosts[$key]})
    ip=${value[1]}
    echo "connecting to $ip"
    sshpass -p ${value[2]} /usr/bin/ssh -o "ProxyCommand connect-proxy -S 127.0.0.1:9889 %h %p" ${value[0]}@$ip
else
    show_keys
fi
