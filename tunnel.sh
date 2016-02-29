#!/bin/bash

if [[ -n `ps -ef | grep 9889 | grep -v grep` ]]; then
    ps -ef | grep 9889 | grep -v grep | awk '{print $2}' | xargs kill -9
fi
nohup sshpass -p "12345678" /usr/bin/ssh  -C -f -N -g -D 9889 abc@hub_ip >/dev/null 2>&1

if [[ -n `ps -ef | grep 9889 | grep -v grep` ]]; then
    echo -e "\033[32mTunnel is created successfully.\033[0m"
else
    echo -e "\033[31mFailed to create tunnel.\033[0m"
fi
