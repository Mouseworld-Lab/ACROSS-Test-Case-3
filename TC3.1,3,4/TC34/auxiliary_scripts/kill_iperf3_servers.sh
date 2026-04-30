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
  echo "Stopping iperf3 on $host..."
  ssh across@$host "pkill -f 'iperf3 -s'"
done
