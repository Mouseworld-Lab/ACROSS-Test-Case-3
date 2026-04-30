#!/bin/bash

# Parámetros SNMP
COMMUNITY="public"
VERSION="2c"

# Validar si el HOST fue proporcionado como parámetro de entrada
if [ -z "$1" ]; then
    read -p "Ingrese la dirección IP o nombre del host: " HOST
else
    HOST=$1
fi

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

echo "===== IfTable ====="
# Recorrer cada índice de interfaz y obtener las métricas dinámicamente
for index in $interface_indices; do
    ip_index=${interface_ips[$index-1]} # Ajuste para obtener la IP correspondiente al índice de la interfaz
    echo "Interface index: $index"
    echo "IP de la interfaz: $ip_index"
    echo "ifInOctets.$index: $(get_snmp_value .1.3.6.1.2.1.2.2.1.10.$index)"
    echo "ifOutOctets.$index: $(get_snmp_value .1.3.6.1.2.1.2.2.1.16.$index)"
    echo "ifOutDiscards.$index: $(get_snmp_value .1.3.6.1.2.1.2.2.1.19.$index)"
    echo "ifInUcastPkts.$index: $(get_snmp_value .1.3.6.1.2.1.2.2.1.11.$index)"
    echo "ifInNUcastPkts.$index: $(get_snmp_value .1.3.6.1.2.1.2.2.1.12.$index)"
    echo "ifInDiscards.$index: $(get_snmp_value .1.3.6.1.2.1.2.2.1.13.$index)"
    echo "ifOutUcastPkts.$index: $(get_snmp_value .1.3.6.1.2.1.2.2.1.17.$index)"
    echo "ifOutNUcastPkts.$index: $(get_snmp_value .1.3.6.1.2.1.2.2.1.18.$index)"
    echo "-----------------------------"
done

echo "===== TcpTable ====="
# TcpTable OIDs
echo "tcpOutRsts: $(get_snmp_value .1.3.6.1.2.1.6.15.0)"
echo "tcpInSegs: $(get_snmp_value .1.3.6.1.2.1.6.10.0)"
echo "tcpOutSegs: $(get_snmp_value .1.3.6.1.2.1.6.11.0)"
echo "tcpPassiveOpens: $(get_snmp_value .1.3.6.1.2.1.6.6.0)"
echo "tcpRetransSegs: $(get_snmp_value .1.3.6.1.2.1.6.12.0)"
echo "tcpCurrEstab: $(get_snmp_value .1.3.6.1.2.1.6.9.0)"
echo "tcpEstabResets: $(get_snmp_value .1.3.6.1.2.1.6.8.0)"
echo "tcpActiveOpens: $(get_snmp_value .1.3.6.1.2.1.6.5.0)"

echo "===== UdpTable ====="
# UdpTable OIDs
echo "udpInDatagrams: $(get_snmp_value .1.3.6.1.2.1.7.1.0)"
echo "udpOutDatagrams: $(get_snmp_value .1.3.6.1.2.1.7.4.0)"
echo "udpInErrors: $(get_snmp_value .1.3.6.1.2.1.7.3.0)"
echo "udpNoPorts: $(get_snmp_value .1.3.6.1.2.1.7.2.0)"

echo "===== IcmpTable ====="
# IcmpTable OIDs
echo "icmpInMsgs: $(get_snmp_value .1.3.6.1.2.1.5.1.0)"
echo "icmpInDestUnreachs: $(get_snmp_value .1.3.6.1.2.1.5.3.0)"
echo "icmpOutMsgs: $(get_snmp_value .1.3.6.1.2.1.5.14.0)"
echo "icmpOutDestUnreachs: $(get_snmp_value .1.3.6.1.2.1.5.15.0)"
echo "icmpInEchos: $(get_snmp_value .1.3.6.1.2.1.5.8.0)"
echo "icmpOutEchoReps: $(get_snmp_value .1.3.6.1.2.1.5.21.0)"

exit 0
