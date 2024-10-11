import subprocess

# Comando para agregar la dirección IP en la interfaz eth1
comando_addr_eth1 = "ip addr add 10.0.12.10/24 dev eth1"
subprocess.run(comando_addr_eth1, shell=True)

comando_addr_eth2 = "ip addr add 11.0.12.11/24 dev eth2"
subprocess.run(comando_addr_eth2, shell=True)

# Definir las rutas a agregar
rutas = [
    "10.0.11.0/24",
    "10.0.13.0/24",
    "10.0.14.0/24",
    "10.0.15.0/24",
    "10.0.16.0/24",
    "10.0.17.0/24",
    "10.0.18.0/24",
    "10.0.19.0/24",
    "192.168.1.0/24",
    "192.168.2.0/24",
    "192.168.3.0/24",
    "192.168.4.0/24",
    "192.168.5.0/24",
    "192.168.6.0/24",
    "192.168.7.0/24",
    "192.168.8.0/24",
    "192.168.9.0/24",
    "192.168.10.0/24",
    "192.168.11.0/24",
    "192.168.12.0/24"
]

# Puerta de enlace y nombre de interfaz comunes para todas las rutas
puerta_enlace = "10.0.12.2"
interfaz = "eth1"

# Agregar cada ruta utilizando subprocess
for ruta in rutas:
    comando = f"ip route add {ruta} via {puerta_enlace} dev {interfaz}"
    subprocess.run(comando, shell=True)

comando_mgmt = f"ip route add 11.0.10.0/24 via {puerta_enlace_eth2} dev {interfaz_eth2}"
subprocess.run(comando_mgmt, shell=True)