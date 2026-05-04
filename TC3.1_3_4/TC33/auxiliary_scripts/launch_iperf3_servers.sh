#!/bin/bash

declare -A nodes_ports=(
  [probe2]="5201"
  [probe3]="5201"
  [probe4]="5201"
  [probe5]="5201 5202"
  [probe6]="5201 5202 5203"
  [probe7]="5201"
  [probe8]="5201 5202"
  [probe9]="5201 5202"
)

for host in "${!nodes_ports[@]}"; do
  ports=${nodes_ports[$host]}
  cmd=""
  for port in $ports; do
    cmd+="nohup iperf3 -s -p $port > iperf3-$port.log 2>&1 & "
  done
  echo "Launching on $host: $cmd"
  ssh across@$host "$cmd"
done
