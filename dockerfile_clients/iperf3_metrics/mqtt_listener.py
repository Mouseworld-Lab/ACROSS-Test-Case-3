import paho.mqtt.client as mqtt
import subprocess
import os
import signal

# Definir la dirección del broker MQTT
broker_address = "11.0.10.11"
topic = "across"
process = None  # Variable para almacenar el proceso

# Callback al recibir un mensaje
def on_message(client, userdata, message):
    global process  # Usar la variable global para el proceso
    msg = message.payload.decode()
    print(f"Mensaje recibido: {msg}")

    if msg == "start":
        # Verificar si el proceso ya se ha terminado
        if process is not None:
            # Si el proceso ha terminado, reiniciar la variable
            if process.poll() is not None:  # None significa que el proceso está en ejecución
                print("El script iperf3_probe.sh ha terminado. Reiniciándolo...")
                process = None
            else:
                print("El script iperf3_probe.sh ya se está ejecutando.")
                return

        print("Ejecutando el script iperf3_probe.sh...")
        process = subprocess.Popen(
            ["/bin/bash", "/home/across/iperf3_metrics/iperf3_probe.sh"],
            stdout=subprocess.PIPE, stderr=subprocess.PIPE,
            preexec_fn=os.setsid  # Crea un nuevo grupo de procesos
        )

    elif msg == "stop":
        if process is not None:
            print("Deteniendo el script iperf3_probe.sh y todos sus procesos asociados...")
            process_pid = process.pid
            # Terminar el proceso y todos sus hijos
            os.killpg(os.getpgid(process_pid), signal.SIGTERM)  # Matar el grupo de procesos
            process.wait()  # Esperar a que el proceso termine
            process = None  # Reiniciar la variable del proceso
            print("El script iperf3_probe.sh y todos los procesos asociados se han detenido.")
        else:
            print("El script iperf3_probe.sh no se está ejecutando.")

    elif msg == "snmp":
        print("Ejecutando el script get_snmp_data.sh...")
        snmp_process = subprocess.Popen(
            ["/bin/bash", "/home/across/get_snmp_data.sh"],
            stdout=subprocess.PIPE, stderr=subprocess.PIPE
        )
        snmp_output, snmp_error = snmp_process.communicate()  # Espera a que termine el script
        print("Salida del script get_snmp_data.sh:")
        print(snmp_output.decode())
        if snmp_error:
            print("Error durante la ejecución de get_snmp_data.sh:")
            print(snmp_error.decode())

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
