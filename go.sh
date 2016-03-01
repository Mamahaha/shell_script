#!/bin/bash

declare db="/home/led/scripts/led"
declare t_hosts="hosts"
declare splitter="|"

#--------------------database operations-----------------------------
function create_db() {
    if [[ ! -f "$db" ]]; then
        printf "No db exists. Will create a new one\n"
        sqlite3 $db "CREATE TABLE $t_hosts(name, ip, user, pswd, info);"
        sqlite3 $db "CREATE INDEX hosts_index on $t_hosts(name);"
    fi
}
function add_host() {
    sqlite3 $db "INSERT INTO $t_hosts VALUES('$1', '$2', '$3', '$4', '$5');"
}
function del_host() {
    sqlite3 $db "DELETE FROM $t_hosts WHERE name='$1';"
}
function show_hosts() {
    printf "\033[1m\033[4m\033[36;40m%-15s\033[0m | \033[1m\033[4m\033[33;40m%-20s\033[0m | \033[1m\033[4m\033[32;40m%s\033[0m\n" "Key" "IP" "Description" 
    str_names=`sqlite3 $db "SELECT name FROM $t_hosts;"`
    names=($str_names)
    for name in ${names[@]}
    do
        host=`sqlite3 $db "SELECT * FROM $t_hosts WHERE name='$name';"`
        OLD_IFS="$IFS"
        IFS=$splitter
        arr=($host)
        IFS="$OLD_IFS"
        printf "\033[36m%-15s\033[0m | \033[33m%-20s\033[0m | \033[32m%s\033[0m\n" "${arr[0]}" "${arr[1]}" "${arr[4]}"
    done
}

function conn_host() {
    host=`sqlite3 $db "SELECT * FROM $t_hosts WHERE name='$1';"`
    if [[ ! -n $host ]]; then
        printf "\033[1m\033[33m%s\033[0m\n" "No such host exist: $1"
    else
        OLD_IFS="$IFS"
        IFS=$splitter
        arr=($host)
        IFS="$OLD_IFS"
        sshpass -p ${arr[3]} /usr/bin/ssh -o "ProxyCommand connect-proxy -S 127.0.0.1:9889 %h %p" ${arr[2]}@${arr[1]}
    fi
}

function scp_file() {
    #sshpass -p 'password' scp user1@server1:/path/from/* user1@server2:/path/to/
    remotep=$1
    localp=$2
    tag="from"
    echo $remotep | grep -q ":"
    if [[ $? != 0 ]]; then
        remotep=$2
        localp=$1
        tag="to"
    fi

    OLD_IFS="$IFS"
    IFS=":"
    rpath=($remotep)
    IFS="$OLD_IFS"
    host=`sqlite3 $db "SELECT * FROM $t_hosts WHERE name='${rpath[0]}';"`
    if [[ ! -n $host ]]; then
        printf "\033[1m\033[33m%s\033[0m\n" "No such host exist: ${rpath[0]}"
    else
        OLD_IFS="$IFS"
        IFS=$splitter
        arr=($host)
        IFS="$OLD_IFS"
        if [[ $tag = "from" ]]; then
            sshpass -p ${arr[3]} scp -o "ProxyCommand connect-proxy -S 127.0.0.1:9889 %h %p" -r ${arr[2]}@${arr[1]}:${rpath[1]} $localp
        else
            sshpass -p ${arr[3]} scp -o "ProxyCommand connect-proxy -S 127.0.0.1:9889 %h %p" -r $localp ${arr[2]}@${arr[1]}:${rpath[1]}
        fi
    fi 
}

#-------------------main function--------------------
create_db
if [[ $# = 1 ]]; then
    printf "\033[1m\033[33m%s\033[0m\n" "Trying to logon to host"
    conn_host $1
else
    case "$1" in
        "a" )
            printf "\033[1m\033[33m%s\033[0m\n" "Trying to add a new host into database"
            add_host $2 $3 $4 $5 "$6";;
        "d" )
            printf "\033[1m\033[33m%s\033[0m\n" "Trying to delete a host from database"
            del_host $2;;
        "to" )
            printf "\033[1m\033[33m%s\033[0m\n" "Trying to logon to host manually"
            #sshpass -p $3 /usr/bin/ssh -o "ProxyCommand connect-proxy -S 127.0.0.1:9889 %h %p" $2;;
            /usr/bin/ssh -o "ProxyCommand connect-proxy -S 127.0.0.1:9889 %h %p " $2;;
        "cp" )
            printf "\033[1m\033[33m%s\033[0m\n" "Trying to copy file from/to remote"
            scp_file $2 $3;;
        * )
            printf "\033[1m\033[31m%s\033[0m\n" "Usage:"
            printf "\033[34m%s\n" " --Add a new host:          > go a 200 10.175.183.200 root 12345678 \"ha ms node\""
            printf " --Delete a host:           > go d 200\n"
            printf " --Logon manually:          > go to root@10.175.183.200 \n"
            printf " --Copy file from remote:   > go cp 200:~/a.txt ~/b.txt\n"
            printf " --Copy file to remote:     > go cp ~/b.txt 200:~/a.txt\n"
            printf "%s\033[0m\n" " --Logon to host:           > go 200"
            show_hosts;;
    esac
fi
