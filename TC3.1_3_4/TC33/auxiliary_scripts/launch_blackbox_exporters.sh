#!/bin/bash

# Lista de nodos donde lanzar el blackbox_exporter
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

# Ruta absoluta del binario y del archivo de configuración en el nodo remoto
exporter_bin="/home/across/blackbox_exporter-0.26.0.linux-amd64/blackbox_exporter"
config_file="/home/across/blackbox_exporter-0.26.0.linux-amd64/blackbox.yml"

for host in "${nodes[@]}"; do
  echo "Starting blackbox_exporter on $host..."
  ssh across@$host "nohup $exporter_bin --config.file=$config_file > blackbox_exporter.log 2>&1 &"
done
