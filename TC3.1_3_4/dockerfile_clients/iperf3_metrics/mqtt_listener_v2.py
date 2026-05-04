import paho.mqtt.client as mqtt
import subprocess
import os
import signal

# Definir la dirección del broker MQTT
broker_address = "11.0.10.11"
topic = "across"
iperf_processes = {}          # Diccionario para almacenar procesos de iperf
snmp_processes = {}           # Diccionario para almacenar procesos de snmp
iperf3_server_processes = {}   # Diccionario para almacenar procesos de iperf3 server

# Función para iniciar un proceso en un nuevo grupo
def start_process(script_path):
    return subprocess.Popen(
        ["/bin/bash", script_path],
        stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        preexec_fn=os.setsid  # Crea un nuevo grupo de procesos
    )

# Función para detener procesos por tipo
def stop_processes(process_dict, process_type):
    for pid, process in process_dict.items():
        print(f"Deteniendo el proceso {process_type} con PID {pid}...")
        os.killpg(os.getpgid(pid), signal.SIGTERM)  # Matar el grupo de procesos
        process.wait()  # Esperar a que el proceso termine
    process_dict.clear()  # Vaciar el diccionario después de detener todos los procesos
    print(f"Todos los procesos {process_type} se han detenido.")

# Callback al recibir un mensaje
def on_message(client, userdata, message):
    global iperf_processes, snmp_processes, iperf3_server_processes  # Usar variables globales
    msg = message.payload.decode()
    print(f"Mensaje recibido: {msg}")

    if msg == "start_iperf3_clients":
        print("Ejecutando una nueva instancia de iperf3_probe.sh...")
        process = start_process("/home/across/iperf3_metrics/iperf3_probe.sh")
        iperf_processes[process.pid] = process
        print(f"Instancia de iperf3_probe.sh iniciada con PID {process.pid}.")

    elif msg == "stop_iperf3_clients":
        if iperf_processes:
            stop_processes(iperf_processes, "iperf")
        else:
            print("No hay procesos iperf en ejecución.")

    elif msg == "start_snmp":
        print("Ejecutando una nueva instancia de get_snmp_data.sh...")
        process = start_process("/home/across/get_snmp_data.sh")
        snmp_processes[process.pid] = process
        print(f"Instancia de get_snmp_data.sh iniciada con PID {process.pid}.")

    elif msg == "stop_snmp":
        if snmp_processes:
            stop_processes(snmp_processes, "snmp")
        else:
            print("No hay procesos snmp en ejecución.")

    elif msg == "start_iperf3_servers":
        print("Ejecutando una nueva instancia de start_iperf3_server.py...")
        process = start_process("/home/across/iperf3_metrics/start_iperf3_server.py")
        iperf3_server_processes[process.pid] = process
        print(f"Instancia de start_iperf3_server.py iniciada con PID {process.pid}.")

    elif msg == "stop_iperf3_servers":
        if iperf3_server_processes:
            stop_processes(iperf3_server_processes, "iperf3 server")
        else:
            print("No hay procesos iperf3 server en ejecución.")

# Crear un cliente MQTT con la versión más reciente
client = mqtt.Client(protocol=mqtt.MQTTv5)

# Asignar el callback
client.on_message = on_message

# Conectar al broker
client.connect(broker_address)

# Suscribirse al topic
client.subscribe(topic)

# Iniciar el bucle
try:
    client.loop_forever()
except Exception as e:
    print(f"Se produjo un error: {e}")
