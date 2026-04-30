import subprocess

# Comando para agregar la dirección IP en la interfaz eth1
comando_addr_eth1 = "ip addr add 192.168.15.1/24 dev eth1"
subprocess.run(comando_addr_eth1, shell=True)

# Comando para agregar la dirección IP en la interfaz eth2
comando_addr_eth2 = "ip addr add 12.12.12.2/24 dev eth2"
subprocess.run(comando_addr_eth2, shell=True)

# Subredes para eth1
subredes_eth1 = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
    "10.0.4.0/24",
    "10.0.5.0/24",
    "10.0.6.0/24",
    "10.0.7.0/24",
    "10.0.8.0/24",
    "10.0.9.0/24",
    "10.0.10.0/24",
    "10.0.11.0/24",
    "10.0.12.0/24",
    "10.0.13.0/24",
    "10.0.14.0/24", 
    "10.0.15.0/24",
    "10.0.16.0/24",
    "10.0.17.0/24",
    "10.0.18.0/24",
    "10.0.19.0/24",
    "10.0.20.0/24",
    "10.0.21.0/24",
    "10.0.22.0/24",
    "10.0.23.0/24",
    "10.0.24.0/24",
    "11.0.1.0/24",
    "11.0.2.0/24",
    "11.0.3.0/24",
    "11.0.4.0/24",
    "11.0.5.0/24",
    "11.0.6.0/24",
    "11.0.7.0/24",
    "11.0.8.0/24",
    "11.0.9.0/24",
    "11.0.10.0/24",
    "11.0.11.0/24",
    "11.0.12.0/24",
    "11.0.13.0/24",
    "11.0.14.0/24",
    "11.0.15.0/24",
    "11.0.16.0/24",
    "11.0.17.0/24",
    "11.0.18.0/24",
    "11.0.19.0/24",
    "11.0.20.0/24",
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
    "192.168.12.0/24",
    "192.168.13.0/24",
    "192.168.14.0/24",  
    "10.0.80.0/24",
    "10.0.81.0/24"
]

# Subredes para eth2
subredes_eth2 = [
    "12.12.12.0/24",
    "192.168.159.0/24",
    # ... (otras subredes para eth2)
]

# Puerta de enlace común para todas las rutas
puerta_enlace_eth1 = "192.168.15.2"
puerta_enlace_eth2 = "12.12.12.1"

#Eliminar y agregar ruta por defecto 
ruta_por_defecto = "default"

# Comando para verificar si la ruta por defecto ya existe
comando_verificar_ruta = f"ip route show | grep {ruta_por_defecto}"

# Ejecutar el comando de verificaci√≥n
resultado = subprocess.run(comando_verificar_ruta, shell=True, stdout=subprocess.PIPE)

# Si la ruta por defecto ya existe, la eliminamos
if resultado.returncode == 0:
    comando_eliminar_ruta = f"ip route del {ruta_por_defecto}"
    subprocess.run(comando_eliminar_ruta, shell=True)

# Agregar la ruta por defecto
comando_ruta_por_defecto = f"ip route add {ruta_por_defecto} via {puerta_enlace_eth2} dev eth2"
subprocess.run(comando_ruta_por_defecto, shell=True)


# Agregar las subredes en eth1
for subred_eth1 in subredes_eth1:
    comando_subred_eth1 = f"ip route add {subred_eth1} via {puerta_enlace_eth1} dev eth1"
    subprocess.run(comando_subred_eth1, shell=True)

# Agregar las subredes en eth2
for subred_eth2 in subredes_eth2:
    comando_subred_eth2 = f"ip route add {subred_eth2} via {puerta_enlace_eth2} dev eth2"
    subprocess.run(comando_subred_eth2, shell=True)
