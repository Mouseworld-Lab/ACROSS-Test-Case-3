#!/bin/bash

# Lista de nodos donde lanzar el exporter
nodes=(
  probe1
  probe2
  probe3
  probe4
  probe6
  probe7
  probe8
  probe9
)

# Ruta absoluta del binario en el nodo remoto
exporter_path="/home/across/iperf3_exporter-1.2.2-linux-amd64/iperf3_exporter"

for host in "${nodes[@]}"; do
  echo "Starting iperf3_exporter on $host..."
  ssh across@$host "nohup $exporter_path > iperf3_exporter_v2.log 2>&1 &"
done
