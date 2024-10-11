#!/bin/bash

hostname=$(cat /etc/hostname)

number=$(echo $hostname | grep -o '[0-9]\+')

if [[ $hostname == client* ]]; then
    sudo python3 "/home/across/routes/routes_client_$number.py"
elif [[ $hostname == server* ]]; then
    sudo python3 "/home/across/routes/routes_server_$number.py"
elif [[ $hostname == broker ]]; then
    sudo python3 "/home/across/routes/routes_broker.py"
else
    echo "Hostname no reconocido: $hostname"
fi
