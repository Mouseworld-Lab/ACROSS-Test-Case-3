#!/bin/bash

# Definir IPs estáticas asociadas a los enlaces
declare -A SERVER_IPS
SERVER_IPS["R1"]="10.0.11.10"
SERVER_IPS["R2"]="10.0.12.10"
SERVER_IPS["R3"]="10.0.13.10"
SERVER_IPS["R4"]="10.0.14.10"
SERVER_IPS["R5"]="10.0.15.10"
SERVER_IPS["R6"]="10.0.16.10"
SERVER_IPS["R7"]="10.0.17.10"
SERVER_IPS["R8"]="10.0.18.10"
SERVER_IPS["R9"]="10.0.19.10"
SERVER_IPS["R10"]="10.0.20.10"

# Obtener el hostname actual del sistema
hostname=$(hostname)

# Ruta base del directorio de configuración
config_dir="/home/across/iperf3_metrics/config_files"

# Construir la ruta del archivo de configuración basado en el hostname
config_file="${config_dir}/iperf3_${hostname}_client.conf"

# Verificar si el archivo de configuración existe
if [[ ! -f "$config_file" ]]; then
    echo "Error: El archivo de configuración $config_file no existe."
    exit 1
fi

# Cargar variables desde el archivo de configuración
source "$config_file"

# Verificar si las variables requeridas están definidas
if [[ -z "$LINKS_TO_MEASURE" || -z "$PROTOCOL" || -z "$BANDWIDTH" || -z "$DURATION" || -z "$POOLING" ]]; then
    echo "Error: Las variables de configuración no están completamente definidas en $config_file"
    exit 1
fi

# Validar que POOLING sea un número positivo
if ! [[ "$POOLING" =~ ^[0-9]+$ ]] || [[ "$POOLING" -le 0 ]]; then
    echo "Error: POOLING debe ser un número entero positivo."
    exit 1
fi

# Configuración de MQTT
BROKER_ADDRESS="11.0.10.11"    # Dirección del broker MQTT
TOPIC="dataset"                # Topic para publicar los datos

# Bucle infinito para ejecutar las mediciones en intervalos definidos por POOLING
while true; do
    # Limpiar archivo temporal
    rm -f /tmp/iperf3_output_R*

    # Asignar puertos según el hostname del probe
    case "$hostname" in
        "probe1")
            PORTS=(5201 5201)
            ;;
        "probe2")
            PORTS=(5201 5202)
            ;;
        "probe3")
            PORTS=(5201 5201)
            ;;
        "probe4")
            PORTS=(5201 5201)
            ;;
        "probe5")
            PORTS=(5202)
            ;;
        "probe6")
            PORTS=(5201 5201)
            ;;
        "probe7")
            PORTS=(5202)
            ;;
        "probe8")
            PORTS=(5202 5203)
            ;;
        *)
            echo "Error: El hostname $hostname no está reconocido."
            exit 1
            ;;
    esac

    # Iterar sobre cada enlace para medir los enlaces en paralelo
    for i in "${!LINKS_TO_MEASURE[@]}"; do
        LINK="${LINKS_TO_MEASURE[$i]}"
        SERVER_IP="${SERVER_IPS[$LINK]}"
        IPERF_PORT="${PORTS[$i]}"

        # Verificar que la IP esté definida para el enlace
        if [[ -z "$SERVER_IP" ]]; then
            echo "Error: No se ha definido una IP para el enlace $LINK"
            continue
        fi

        # Definir el sentido de la medición basado en el nombre del enlace
        probe_name=$(echo "$LINK" | sed 's/R/probe/')
        direction="${hostname}-$probe_name"

        # Ejecutar iperf3 en segundo plano y guardar la salida en un archivo temporal único por cada enlace
        iperf3 -c "$SERVER_IP" $PROTOCOL $BANDWIDTH $DURATION --port "$IPERF_PORT" --logfile /tmp/iperf3_output_"$direction" &
    done

    # Esperar a que todas las ejecuciones de iperf3 finalicen
    wait

    # Procesar los resultados de cada archivo temporal
    for LINK in "${LINKS_TO_MEASURE[@]}"; do
        SERVER_IP="${SERVER_IPS[$LINK]}"
        probe_name=$(echo "$LINK" | sed 's/R/probe/')
        direction="${hostname}-$probe_name"

        # Verificar que la IP esté definida para el enlace
        if [[ -z "$SERVER_IP" ]]; then
            echo "Error: No se ha definido una IP para el enlace $LINK"
            continue
        fi

        # Extraer las líneas relevantes del archivo temporal
        output=$(tail -n 4 /tmp/iperf3_output_"$direction" | head -n 2)

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

        # Generar la salida en formato CSV con la IP del servidor y el sentido de la medición
        csv_line="$epoch, $direction, $sender_interval, $sender_transfer, $sender_bitrate, $sender_jitter, $sender_lost, $receiver_interval, $receiver_transfer, $receiver_bitrate, $receiver_jitter, $receiver_lost"
        
        # Guardar en el archivo CSV
        echo "$csv_line" >> /tmp/iperf3_results.csv

        # Publicar cada línea en el broker MQTT
        mosquitto_pub -h "$BROKER_ADDRESS" -t "$TOPIC" -m "$csv_line"

        echo "Publicado en MQTT: $csv_line"

        # Limpiar archivo temporal
        rm -f /tmp/iperf3_output_"$direction"
    done

    # Esperar el tiempo definido en POOLING antes de la próxima ejecución
    sleep "$POOLING"
done
