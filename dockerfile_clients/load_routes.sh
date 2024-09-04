#!/bin/bash

hostname=$(cat /etc/hostname)

number=$(echo $hostname | grep -o '[0-9]\+')

if [[ $hostname == client* ]]; then
    sudo python3 "/home/across/routes/routes_client_$number.py"
elif [[ $hostname == server* ]]; then
    sudo python3 "/home/acrossroutes/routes_server_$number.py"
else
    echo "Hostname no reconocido: $hostname"
fi
