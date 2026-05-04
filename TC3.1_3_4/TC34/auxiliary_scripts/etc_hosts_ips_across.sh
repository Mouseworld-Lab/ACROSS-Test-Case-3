#!/bin/bash

# Escribir la cabecera
echo '# IPs escenario across KNE' | sudo tee -a /etc/hosts > /dev/null

# Ejecutar el comando kubectl para obtener los servicios
kubectl get services -n 10-ceos-tc33 | awk 'NR>1 {print $4, $1}' | while read ip name; do
    # Asociar IP a nombre solo si el nombre empieza con 'service-probe', 'service-server' o 'service-r'
    case $name in
        service-probe1) hostname="probe1";;
        service-probe2) hostname="probe2";;
        service-probe3) hostname="probe3";;
        service-probe4) hostname="probe4";;
        service-probe5) hostname="probe5";;
        service-probe6) hostname="probe6";;
        service-probe7) hostname="probe7";;
        service-probe8) hostname="probe8";;
        service-probe9) hostname="probe9";;
        service-server1-1) hostname="server1-1";;
        service-server1-2) hostname="server1-2";;
        service-server1-3) hostname="server1-3";;
        service-server1-4) hostname="server1-4";;
        service-server1-5) hostname="server1-5";;
        service-server2) hostname="server2";;
        service-server3) hostname="server3";;
        service-r1) hostname="r1";;
        service-r2) hostname="r2";;
        service-r3) hostname="r3";;
        service-r4) hostname="r4";;
        service-r5) hostname="r5";;
        service-r6) hostname="r6";;
        service-r7) hostname="r7";;
        service-r8) hostname="r8";;
        service-r9) hostname="r9";;
        service-r10) hostname="r10";;
        *) continue ;;  # Ignorar cualquier servicio que no sea 'probe', 'server' o 'r'
    esac
    # Escribir la IP y el nombre en /etc/hosts
    echo "$ip $hostname" | sudo tee -a /etc/hosts > /dev/null
done
