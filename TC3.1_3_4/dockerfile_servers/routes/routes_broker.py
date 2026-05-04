import subprocess

# Comando para agregar la dirección IP en la interfaz eth1
comando_addr = "ip addr add 11.0.10.11/24 dev eth1"
subprocess.run(comando_addr, shell=True)

# Definir las rutas a agregar
rutas = [
    "11.0.11.0/24",
    "11.0.12.0/24",
    "11.0.13.0/24",
    "11.0.14.0/24",
    "11.0.15.0/24",
    "11.0.16.0/24",
    "11.0.17.0/24",
    "11.0.18.0/24",
    "11.0.19.0/24",
]

# Puerta de enlace y nombre de interfaz comunes para todas las rutas
puerta_enlace = "11.0.10.1"
interfaz = "eth1"

# Agregar cada ruta utilizando subprocess
for ruta in rutas:
    comando = f"ip route add {ruta} via {puerta_enlace} dev {interfaz}"
    subprocess.run(comando, shell=True)
