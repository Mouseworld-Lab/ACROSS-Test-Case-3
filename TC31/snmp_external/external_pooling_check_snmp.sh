#!/bin/bash

TIMESTAMP_MQTT=$1

echo ""
echo "Timestamp recibido: $TIMESTAMP_MQTT"

# Parámetros SNMP
COMMUNITY="public"
VERSION="2c"
HOST="r1"

CONTADOR=0

# Parámetros MQTT
MQTT_HOST="11.0.10.11"
MQTT_TOPIC="dataset_snmp"

# Tiempo de pooling en segundos
POOLING=10  # Puedes cambiar este valor para ajustar el tiempo entre cada recolección

# Función para recolectar un valor SNMP
function get_snmp_value() {
    local oid=$1
    snmpget -v $VERSION -c $COMMUNITY $HOST $oid | awk '{print $NF}'
}

# Función para obtener los índices de las interfaces
function get_interface_indices() {
    snmpwalk -v $VERSION -c $COMMUNITY $HOST .1.3.6.1.2.1.2.2.1.2 | awk -F '.' '{print $NF}' | awk '{print $1}'
}

# Obtener el nombre del sistema
SYS_NAME=$(get_snmp_value .1.3.6.1.2.1.1.5.0)

# Número máximo de interfaces para llenar el CSV (2 a 7)
MAX_INTERFACES=6
INTERFACE_START=2

# Timestamp en formato epoch
TIMESTAMP=$(date +%s)

# Generar nombre del archivo CSV
CSV_FILE="snmp_data_test.csv"
csv_values_ref=""

# Bucle infinito con intervalo de pooling
while true; do
    start_time=$(date +%s)  # Guardar el tiempo de inicio de la iteración
    echo "Timestamp_mqtt: $TIMESTAMP_MQTT"

    # Detectar los índices de las interfaces
    interface_indices=$(get_interface_indices)

    # Inicializar la cadena para el CSV TIMESTAMP_MQTT
    csv_header="Interfaces,Host Name,Timestamp,Nº de interfaces detectadas,"
    csv_values="$MAX_INTERFACES,$SYS_NAME,$TIMESTAMP_MQTT,$(echo "$interface_indices" | wc -w),"

    # TcpTable OIDs
    tcpOutRsts=$(get_snmp_value .1.3.6.1.2.1.6.15.0)
    csv_header+="tcpOutRsts,"
    csv_values+="$tcpOutRsts,"

    tcpInSegs=$(get_snmp_value .1.3.6.1.2.1.6.10.0)
    csv_header+="tcpInSegs,"
    csv_values+="$tcpInSegs,"

    tcpOutSegs=$(get_snmp_value .1.3.6.1.2.1.6.11.0)
    csv_header+="tcpOutSegs,"
    csv_values+="$tcpOutSegs,"

    tcpPassiveOpens=$(get_snmp_value .1.3.6.1.2.1.6.6.0)
    csv_header+="tcpPassiveOpens,"
    csv_values+="$tcpPassiveOpens,"

    tcpRetransSegs=$(get_snmp_value .1.3.6.1.2.1.6.12.0)
    csv_header+="tcpRetransSegs,"
    csv_values+="$tcpRetransSegs,"

    tcpCurrEstab=$(get_snmp_value .1.3.6.1.2.1.6.9.0)
    csv_header+="tcpCurrEstab,"
    csv_values+="$tcpCurrEstab,"

    tcpEstabResets=$(get_snmp_value .1.3.6.1.2.1.6.8.0)
    csv_header+="tcpEstabResets,"
    csv_values+="$tcpEstabResets,"

    tcpActiveOpens=$(get_snmp_value .1.3.6.1.2.1.6.5.0)
    csv_header+="tcpActiveOpens,"
    csv_values+="$tcpActiveOpens,"

    # UdpTable OIDs
    udpInDatagrams=$(get_snmp_value .1.3.6.1.2.1.7.1.0)
    csv_header+="udpInDatagrams,"
    csv_values+="$udpInDatagrams,"

    udpOutDatagrams=$(get_snmp_value .1.3.6.1.2.1.7.4.0)
    csv_header+="udpOutDatagrams,"
    csv_values+="$udpOutDatagrams,"

    udpInErrors=$(get_snmp_value .1.3.6.1.2.1.7.3.0)
    csv_header+="udpInErrors,"
    csv_values+="$udpInErrors,"

    # Recorrer los índices del rango definido
    for index in $(seq $INTERFACE_START $(($INTERFACE_START + $MAX_INTERFACES - 1))); do
        if echo "$interface_indices" | grep -q "\<$index\>"; then
            # Si el índice está disponible, obtener métricas reales
            ifInOctets=$(get_snmp_value .1.3.6.1.2.1.2.2.1.10.$index)
            ifOutOctets=$(get_snmp_value .1.3.6.1.2.1.2.2.1.16.$index)
            ifOutDiscards=$(get_snmp_value .1.3.6.1.2.1.2.2.1.19.$index)
            ifInUcastPkts=$(get_snmp_value .1.3.6.1.2.1.2.2.1.11.$index)
            ifInNUcastPkts=$(get_snmp_value .1.3.6.1.2.1.2.2.1.12.$index)
            ifInDiscards=$(get_snmp_value .1.3.6.1.2.1.2.2.1.13.$index)
            ifOutUcastPkts=$(get_snmp_value .1.3.6.1.2.1.2.2.1.17.$index)
            ifOutNUcastPkts=$(get_snmp_value .1.3.6.1.2.1.2.2.1.18.$index)
            #new parameters
            hostInPkts=$(get_snmp_value .1.3.6.1.2.1.16.1.7.1.2.$index)
            hostOutPkts=$(get_snmp_value .1.3.6.1.2.1.16.1.7.1.4.$index)
            etherStatsCollisions=$(get_snmp_value .1.3.6.1.2.1.16.1.1.1.14.$index)
            etherStatsCRCAlignErrors=$(get_snmp_value .1.3.6.1.2.1.16.1.1.1.15.$index)
            etherStatsUndersizePkts=$(get_snmp_value .1.3.6.1.2.1.16.1.1.1.16.$index)
            etherStatsOversizePkts=$(get_snmp_value .1.3.6.1.2.1.16.1.1.1.17.$index)
            etherStatsFragments=$(get_snmp_value .1.3.6.1.2.1.16.1.1.1.18.$index)
            etherStatsJabbers=$(get_snmp_value .1.3.6.1.2.1.16.1.1.1.19.$index)
            etherStatsOctets=$(get_snmp_value .1.3.6.1.2.1.16.1.1.1.4.$index)
            etherStatsPkts=$(get_snmp_value .1.3.6.1.2.1.16.1.1.1.5.$index)
            etherStatsBroadcastPkts=$(get_snmp_value .1.3.6.1.2.1.16.1.1.1.6.$index)
            etherStatsMulticastPkts=$(get_snmp_value .1.3.6.1.2.1.16.1.1.1.7.$index)
        else
            # Si no existe el índice, rellenar con "null"
            ifInOctets="null"
            ifOutOctets="null"
            ifOutDiscards="null"
            ifInUcastPkts="null"
            ifInNUcastPkts="null"
            ifInDiscards="null"
            ifOutUcastPkts="null"
            ifOutNUcastPkts="null"
            #new parameters
            hostInPkts="null"
            hostOutPkts="null"
            etherStatsCollisions="null"
            etherStatsCRCAlignErrors="null"
            etherStatsUndersizePkts="null"
            etherStatsOversizePkts="null"
            etherStatsFragments="null"
            etherStatsJabbers="null"
            etherStatsOctets="null"
            etherStatsPkts="null"
            etherStatsBroadcastPkts="null"
            etherStatsMulticastPkts="null"
        fi

        # Agregar los valores al CSV
        csv_header+="ifInOctets.$index,ifOutOctets.$index,ifOutDiscards.$index,ifInUcastPkts.$index,ifInNUcastPkts.$index,ifInDiscards.$index,ifOutUcastPkts.$index,ifOutNUcastPkts.$index,hostInPkts.$index,hostOutPkts.$index,etherStatsCollisions.$index,etherStatsCRCAlignErrors.$index,etherStatsUndersizePkts.$index,etherStatsOversizePkts.$index,etherStatsFragments.$index,etherStatsJabbers.$index,etherStatsOctets.$index,etherStatsPkts.$index,etherStatsBroadcastPkts.$index,etherStatsMulticastPkts.$index,"
        csv_values+="$ifInOctets,$ifOutOctets,$ifOutDiscards,$ifInUcastPkts,$ifInNUcastPkts,$ifInDiscards,$ifOutUcastPkts,$ifOutNUcastPkts,$hostInPkts,$hostOutPkts,$etherStatsCollisions,$etherStatsCRCAlignErrors,$etherStatsUndersizePkts,$etherStatsOversizePkts,$etherStatsFragments,$etherStatsJabbers,$etherStatsOctets,$etherStatsPkts,$etherStatsBroadcastPkts,$etherStatsMulticastPkts,"
    done

    # Crear el archivo CSV y subir los datos a MQTT
    if [ ! -f "$CSV_FILE" ]; then
        echo "$csv_header" > "$CSV_FILE"
    fi

    #echo "Referencia: $csv_values_ref"
    if [ -z "$csv_values_ref" ]; then
        csv_values_ref="$csv_values"
        echo "Primera iteración: valores base guardados, no se escribe en CSV."
    else
        # Calcular la diferencia entre valores actuales y previos, preservando valores no numéricos
        csv_diff=$(paste -d',' <(echo "$csv_values_ref" | tr ',' '\n') <(echo "$csv_values" | tr ',' '\n') |
            awk -F',' '{
                if (NR <= 4) {
                    # Las primeras 4 columnas se copian de los valores de referencia
                    print $1
                } else if ($1 ~ /^[0-9]+$/ && $2 ~ /^[0-9]+$/) {
                    # Resto si ambos son numéricos
                    print $2 - $1
                } else {
                    # Conservo el valor actual si no es numérico
                    print $2
                }
            }' | tr '\n' ',' | sed 's/,$//')

        echo "Diferencias: $csv_diff"
        # Escribir la diferencia en el archivo CSV
        echo "$csv_diff" >> "$CSV_FILE"

        # Publicar la diferencia en el servidor MQTT
        #mosquitto_pub -h $MQTT_HOST -t $MQTT_TOPIC -m "$csv_diff"

        # Actualizar los valores previos
        csv_values_ref="$csv_values"
    fi

#    # Publicar el archivo CSV en el servidor MQTT
#    mosquitto_pub -h $MQTT_HOST -t $MQTT_TOPIC -m "$csv_values"

    # Esperar antes de la próxima ejecución
    end_time=$(date +%s)    # Guardar el tiempo después de ejecutar sondeo_snmp
    duration=$((end_time - start_time))  # Calcular la duración de sondeo_snmp

    sleep_time=$(($POOLING - duration))  # Calcular el tiempo de sueño necesario para completar 10 segundos

    if [ $sleep_time -gt 0 ]; then
        sleep $sleep_time  # Dormir el tiempo restante para completar 10 segundos
    fi

    TIMESTAMP_MQTT=$((TIMESTAMP_MQTT + POOLING))
    ((CONTADOR++))
    echo "Contador: $CONTADOR"
done
