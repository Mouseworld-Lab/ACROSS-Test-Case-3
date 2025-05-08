#!/bin/bash

TIMESTAMP_MQTT=$1

#if [ -z "$TIMESTAMP_MQTT" ]; then
#    echo "Uso: $0 <timestamp_mqtt>"
#    exit 1
#fi

echo ""
echo "Timestamp recibido: $TIMESTAMP_MQTT"

# Parámetros SNMP
COMMUNITY="public"
VERSION="2c"

# Lista de hosts
HOSTS=(r1 r2 r3 r4 r5 r6 r7 r8 r9)

# Parámetros MQTT
MQTT_HOST="11.0.10.11"
MQTT_TOPIC="dataset_snmp"

# Tiempo de pooling en segundos
POOLING=10

# Número máximo de interfaces para llenar el CSV (2 a 7)
MAX_INTERFACES=6
INTERFACE_START=2

# Función para recolectar métricas SNMP de un host
colectar_snmp_para_host() {
    local HOST="$1"
    local TIMESTAMP=$(date +%s)
    local CSV_FILE="snmp_data_${HOST}.csv"

    # Función para hacer SNMPGET
    get_snmp_value() {
        local oid=$1
        snmpget -v $VERSION -c $COMMUNITY $HOST $oid | awk '{print $NF}'
    }

    get_interface_indices() {
        snmpwalk -v $VERSION -c $COMMUNITY $HOST .1.3.6.1.2.1.2.2.1.2 | awk -F '.' '{print $NF}' | awk '{print $1}'
    }

    local SYS_NAME=$(get_snmp_value .1.3.6.1.2.1.1.5.0)
    local interface_indices=$(get_interface_indices)

    local csv_header="Interfaces,Host Name,Timestamp,Nº de interfaces detectadas,"
    local csv_values="$MAX_INTERFACES,$SYS_NAME,$TIMESTAMP_MQTT,$(echo "$interface_indices" | wc -w),"

    # TCP
    for oid in 6.15.0 6.10.0 6.11.0 6.6.0 6.12.0 6.9.0 6.8.0 6.5.0; do
        val=$(get_snmp_value ".1.3.6.1.2.1.${oid}")
        name=$(echo $oid | awk -F '.' '{ 
            if ($NF==15) print "tcpOutRsts"
            else if ($NF==10) print "tcpInSegs"
            else if ($NF==11) print "tcpOutSegs"
            else if ($NF==6) print "tcpPassiveOpens"
            else if ($NF==12) print "tcpRetransSegs"
            else if ($NF==9) print "tcpCurrEstab"
            else if ($NF==8) print "tcpEstabResets"
            else if ($NF==5) print "tcpActiveOpens"
        }')
        csv_header+="${name},"
        csv_values+="$val,"
    done

    # UDP
    for oid in 7.1.0 7.4.0 7.3.0; do
        val=$(get_snmp_value ".1.3.6.1.2.1.${oid}")
        name=$(echo $oid | awk -F '.' '{
            if ($NF==1) print "udpInDatagrams"
            else if ($NF==4) print "udpOutDatagrams"
            else if ($NF==3) print "udpInErrors"
        }')
        csv_header+="${name},"
        csv_values+="$val,"
    done

    for index in $(seq $INTERFACE_START $(($INTERFACE_START + $MAX_INTERFACES - 1))); do
        if echo "$interface_indices" | grep -q "\<$index\>"; then
            # Obtener métricas
            for oid in 2.2.1.10 2.2.1.16 2.2.1.19 2.2.1.11 2.2.1.12 2.2.1.13 2.2.1.17 2.2.1.18; do
                val=$(get_snmp_value ".1.3.6.1.$oid.$index")
                name=$(echo $oid | awk -F '.' '{
                    if ($4==10) print "ifInOctets"
                    else if ($4==16) print "ifOutOctets"
                    else if ($4==19) print "ifOutDiscards"
                    else if ($4==11) print "ifInUcastPkts"
                    else if ($4==12) print "ifInNUcastPkts"
                    else if ($4==13) print "ifInDiscards"
                    else if ($4==17) print "ifOutUcastPkts"
                    else if ($4==18) print "ifOutNUcastPkts"
                }')
                csv_header+="${name}.${index},"
                csv_values+="$val,"
            done
            # Nuevos parámetros
            for oid in 16.1.7.1.2 16.1.7.1.4 16.1.1.1.14 16.1.1.1.15 16.1.1.1.16 16.1.1.1.17 16.1.1.1.18 16.1.1.1.19 16.1.1.1.4 16.1.1.1.5 16.1.1.1.6 16.1.1.1.7; do
                val=$(get_snmp_value ".1.3.6.1.$oid.$index")
                name=$(echo $oid | awk -F '.' '{
                    if ($5==2) print "hostInPkts"
                    else if ($5==4) print "hostOutPkts"
                    else if ($5==14) print "etherStatsCollisions"
                    else if ($5==15) print "etherStatsCRCAlignErrors"
                    else if ($5==16) print "etherStatsUndersizePkts"
                    else if ($5==17) print "etherStatsOversizePkts"
                    else if ($5==18) print "etherStatsFragments"
                    else if ($5==19) print "etherStatsJabbers"
                    else if ($5==4 && $4==1) print "etherStatsOctets"
                    else if ($5==5) print "etherStatsPkts"
                    else if ($5==6) print "etherStatsBroadcastPkts"
                    else if ($5==7) print "etherStatsMulticastPkts"
                }')
                csv_header+="${name}.${index},"
                csv_values+="$val,"
            done
        else
            # No disponible
            for metric in ifInOctets ifOutOctets ifOutDiscards ifInUcastPkts ifInNUcastPkts ifInDiscards ifOutUcastPkts ifOutNUcastPkts hostInPkts hostOutPkts etherStatsCollisions etherStatsCRCAlignErrors etherStatsUndersizePkts etherStatsOversizePkts etherStatsFragments etherStatsJabbers etherStatsOctets etherStatsPkts etherStatsBroadcastPkts etherStatsMulticastPkts; do
                csv_header+="${metric}.${index},"
                csv_values+="null,"
            done
        fi
    done

    if [ ! -f "$CSV_FILE" ]; then
        echo "$csv_header" > "$CSV_FILE"
    fi
    echo "$csv_values" >> "$CSV_FILE"

    # Puedes publicar a MQTT si lo deseas:
    # mosquitto_pub -h "$MQTT_HOST" -t "$MQTT_TOPIC" -m "$csv_values"
}

# Bucle principal de pooling
while true; do
    echo "----- Recolección SNMP [$TIMESTAMP_MQTT] -----"
    for HOST in "${HOSTS[@]}"; do
        colectar_snmp_para_host "$HOST" &
    done
    wait
    echo "Recolección completada. Esperando $POOLING segundos..."
    sleep "$POOLING"
done
