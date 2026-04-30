#!/bin/bash

# Parámetros SNMP
COMMUNITY="public"
VERSION="2c"
HOST="10.0.12.2"

# Validar si el HOST fue proporcionado como parámetro de entrada
#if [ -z "$1" ]; then
#    read -p "Ingrese la dirección IP o nombre del host: " HOST
#else
#    HOST=$1
#fi

# Función para recolectar un valor SNMP
function get_snmp_value() {
    local oid=$1
    snmpget -v $VERSION -c $COMMUNITY $HOST $oid | awk '{print $NF}'
}

# Función para obtener los índices de las interfaces
function get_interface_indices() {
    snmpwalk -v $VERSION -c $COMMUNITY $HOST .1.3.6.1.2.1.2.2.1.2 | awk -F '.' '{print $NF}' | awk '{print $1}'
}

# Función para obtener las direcciones IP de las interfaces usando IP-MIB::ipAdEntAddr
function get_interface_ips() {
    snmpwalk -v $VERSION -c $COMMUNITY $HOST IP-MIB::ipAdEntAddr | awk '{print $NF}'
}

# Obtener el nombre del sistema
SYS_NAME=$(get_snmp_value .1.3.6.1.2.1.1.5.0)

# Obtener la dirección IP del host
IP_HOST=$(get_snmp_value .1.3.6.1.2.1.4.20.1.2)

# Timestamp en formato epoch
TIMESTAMP=$(date +%s)

# Generar nombre del archivo CSV
CSV_FILE="snmp_data_test.csv"

echo "===== Información del Host ====="
echo "Host IP: $HOST"
echo "Host Name: $SYS_NAME"
echo "Timestamp: $TIMESTAMP"
echo "==============================="

echo "===== Interfaces detectadas ====="
# Detectar los índices de las interfaces
interface_indices=$(get_interface_indices)
echo "Índices detectados: $interface_indices"

# Obtener las direcciones IP de las interfaces
interface_ips=($(get_interface_ips))

# Inicializar la cadena para el CSV
csv_header="Host IP,Host Name,Timestamp,Nº de interfaces detectadas,"
csv_values="$IP_HOST,$SYS_NAME,$TIMESTAMP,$(echo "$interface_indices" | wc -w),"

echo "===== IfTable ====="
# Recorrer cada índice de interfaz y obtener las métricas dinámicamente
for index in $interface_indices; do
    ip_index=${interface_ips[$index-1]} # Ajuste para obtener la IP correspondiente al índice de la interfaz
    echo "Interface index: $index"
    echo "IP de la interfaz: $ip_index"

    ifInOctets=$(get_snmp_value .1.3.6.1.2.1.2.2.1.10.$index)
    echo "ifInOctets.$index: $ifInOctets"
    csv_header+="ifInOctets.$index,"
    csv_values+="$ifInOctets,"

    ifOutOctets=$(get_snmp_value .1.3.6.1.2.1.2.2.1.16.$index)
    echo "ifOutOctets.$index: $ifOutOctets"
    csv_header+="ifOutOctets.$index,"
    csv_values+="$ifOutOctets,"

    ifOutDiscards=$(get_snmp_value .1.3.6.1.2.1.2.2.1.19.$index)
    echo "ifOutDiscards.$index: $ifOutDiscards"
    csv_header+="ifOutDiscards.$index,"
    csv_values+="$ifOutDiscards,"

    ifInUcastPkts=$(get_snmp_value .1.3.6.1.2.1.2.2.1.11.$index)
    echo "ifInUcastPkts.$index: $ifInUcastPkts"
    csv_header+="ifInUcastPkts.$index,"
    csv_values+="$ifInUcastPkts,"

    ifInNUcastPkts=$(get_snmp_value .1.3.6.1.2.1.2.2.1.12.$index)
    echo "ifInNUcastPkts.$index: $ifInNUcastPkts"
    csv_header+="ifInNUcastPkts.$index,"
    csv_values+="$ifInNUcastPkts,"

    ifInDiscards=$(get_snmp_value .1.3.6.1.2.1.2.2.1.13.$index)
    echo "ifInDiscards.$index: $ifInDiscards"
    csv_header+="ifInDiscards.$index,"
    csv_values+="$ifInDiscards,"

    ifOutUcastPkts=$(get_snmp_value .1.3.6.1.2.1.2.2.1.17.$index)
    echo "ifOutUcastPkts.$index: $ifOutUcastPkts"
    csv_header+="ifOutUcastPkts.$index,"
    csv_values+="$ifOutUcastPkts,"

    ifOutNUcastPkts=$(get_snmp_value .1.3.6.1.2.1.2.2.1.18.$index)
    echo "ifOutNUcastPkts.$index: $ifOutNUcastPkts"
    csv_header+="ifOutNUcastPkts.$index,"
    csv_values+="$ifOutNUcastPkts,"

    echo "-----------------------------"
done

echo "===== TcpTable ====="
# TcpTable OIDs
tcpOutRsts=$(get_snmp_value .1.3.6.1.2.1.6.15.0)
echo "tcpOutRsts: $tcpOutRsts"
csv_header+="tcpOutRsts,"
csv_values+="$tcpOutRsts,"

tcpInSegs=$(get_snmp_value .1.3.6.1.2.1.6.10.0)
echo "tcpInSegs: $tcpInSegs"
csv_header+="tcpInSegs,"
csv_values+="$tcpInSegs,"

tcpOutSegs=$(get_snmp_value .1.3.6.1.2.1.6.11.0)
echo "tcpOutSegs: $tcpOutSegs"
csv_header+="tcpOutSegs,"
csv_values+="$tcpOutSegs,"

tcpPassiveOpens=$(get_snmp_value .1.3.6.1.2.1.6.6.0)
echo "tcpPassiveOpens: $tcpPassiveOpens"
csv_header+="tcpPassiveOpens,"
csv_values+="$tcpPassiveOpens,"

tcpRetransSegs=$(get_snmp_value .1.3.6.1.2.1.6.12.0)
echo "tcpRetransSegs: $tcpRetransSegs"
csv_header+="tcpRetransSegs,"
csv_values+="$tcpRetransSegs,"

tcpCurrEstab=$(get_snmp_value .1.3.6.1.2.1.6.9.0)
echo "tcpCurrEstab: $tcpCurrEstab"
csv_header+="tcpCurrEstab,"
csv_values+="$tcpCurrEstab,"

tcpEstabResets=$(get_snmp_value .1.3.6.1.2.1.6.8.0)
echo "tcpEstabResets: $tcpEstabResets"
csv_header+="tcpEstabResets,"
csv_values+="$tcpEstabResets,"

tcpActiveOpens=$(get_snmp_value .1.3.6.1.2.1.6.5.0)
echo "tcpActiveOpens: $tcpActiveOpens"
csv_header+="tcpActiveOpens,"
csv_values+="$tcpActiveOpens,"

echo "===== UdpTable ====="
# UdpTable OIDs
udpInDatagrams=$(get_snmp_value .1.3.6.1.2.1.7.1.0)
echo "udpInDatagrams: $udpInDatagrams"
csv_header+="udpInDatagrams,"
csv_values+="$udpInDatagrams,"

udpOutDatagrams=$(get_snmp_value .1.3.6.1.2.1.7.4.0)
echo "udpOutDatagrams: $udpOutDatagrams"
csv_header+="udpOutDatagrams,"
csv_values+="$udpOutDatagrams,"

udpInErrors=$(get_snmp_value .1.3.6.1.2.1.7.3.0)
echo "udpInErrors: $udpInErrors"
csv_header+="udpInErrors,"
csv_values+="$udpInErrors,"

udpNoPorts=$(get_snmp_value .1.3.6.1.2.1.7.2.0)
echo "udpNoPorts: $udpNoPorts"
csv_header+="udpNoPorts,"
csv_values+="$udpNoPorts,"

echo "===== IcmpTable ====="
# IcmpTable OIDs
icmpInMsgs=$(get_snmp_value .1.3.6.1.2.1.5.1.0)
echo "icmpInMsgs: $icmpInMsgs"
csv_header+="icmpInMsgs,"
csv_values+="$icmpInMsgs,"

icmpOutMsgs=$(get_snmp_value .1.3.6.1.2.1.5.2.0)
echo "icmpOutMsgs: $icmpOutMsgs"
csv_header+="icmpOutMsgs,"
csv_values+="$icmpOutMsgs,"

# Eliminar la última coma del header y los valores
csv_header=${csv_header%,}
csv_values=${csv_values%,}

# Verificar si el archivo CSV ya existe
if [ ! -f "$CSV_FILE" ]; then
    # Si el archivo no existe, crear el archivo y agregar el encabezado
    echo "$csv_header" > "$CSV_FILE"
fi

# Agregar los valores en una nueva línea
echo "$csv_values" >> "$CSV_FILE"

# Imprimir el contenido del archivo CSV
echo "Contenido del archivo CSV:"
cat "$CSV_FILE"
