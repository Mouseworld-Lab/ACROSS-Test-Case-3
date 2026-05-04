#!/bin/bash

# Comunidad SNMP y OID para sysName
COMMUNITY="public"
OID="1.3.6.1.2.1.1.5.0"

# Lista de routers
routers=(r1 r2 r3 r4 r5 r6 r7 r8 r9)

# Función para consultar un router
check_sysname() {
    local router="$1"
    local result
    result=$(snmpget -v2c -c "$COMMUNITY" -Oqv "$router" "$OID" 2>/dev/null)
    local epoch=$(date +%s)
    if [ -z "$result" ]; then
        echo "$epoch $router: sin respuesta"
    else
        echo "$epoch $router: $result"
    fi
}

# Lanzar en paralelo
for router in "${routers[@]}"; do
    check_sysname "$router" &
done

# Esperar a que terminen todas las tareas
wait
