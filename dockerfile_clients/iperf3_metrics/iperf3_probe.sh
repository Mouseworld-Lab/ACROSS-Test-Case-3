#!/bin/bash

# Cargar variables desde el archivo de configuración
source /home/across/iperf3_metrics/iperf3_probe.conf

# Ejecutar iperf3 y guardar la salida
iperf3 -c "$SERVER_IP" $PROTOCOL $BANDWIDTH $DURATION --logfile /tmp/iperf3_output

# Extraer las líneas relevantes
output=$(tail -n 4 /tmp/iperf3_output | head -n 2)

# Procesar las líneas para extraer los datos deseados
sender_line=$(echo "$output" | head -n 1)
receiver_line=$(echo "$output" | tail -n 1)

# Obtener los datos del sender
sender_interval=$(echo "$sender_line" | awk '{print $3}')
sender_transfer=$(echo "$sender_line" | awk '{print $5, $6}')
sender_bitrate=$(echo "$sender_line" | awk '{print $7, $8}')
sender_jitter=$(echo "$sender_line" | awk '{print $9, $10}')
sender_lost=$(echo "$sender_line" | awk '{print $12}' | sed 's/[()]//g')

# Obtener los datos del receiver
receiver_interval=$(echo "$receiver_line" | awk '{print $3}')
receiver_transfer=$(echo "$receiver_line" | awk '{print $5, $6}')
receiver_bitrate=$(echo "$receiver_line" | awk '{print $7, $8}')
receiver_jitter=$(echo "$receiver_line" | awk '{print $9, $10}')
receiver_lost=$(echo "$receiver_line" | awk '{print $12}' | sed 's/[()]//g')

# Obtener la época actual
epoch=$(date +%s)

# Generar la salida en formato CSV
echo "$epoch, $sender_interval, $sender_transfer, $sender_bitrate, $sender_jitter, $sender_lost, $receiver_interval, $receiver_transfer, $receiver_bitrate, $receiver_jitter, $receiver_lost" >> /tmp/iperf3_results.csv
