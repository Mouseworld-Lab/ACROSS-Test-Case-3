import subprocess
import time
import socket

# Obtener el hostname del sistema
host = socket.gethostname()

# Diccionario de configuraciones de puertos según hostname
config = {
    "probe1": [],
    "probe2": [5201],
    "probe3": [5201],
    "probe4": [5201],
    "probe5": [5201],
    "probe7": [5201],
    "probe6": [5201, 5202],
    "probe8": [5201, 5202, 5203],
    "probe9": [5201, 5202, 5203],
}

# Iniciar iperf3 en los puertos correspondientes al hostname
def start_iperf3(port):
    try:
        return subprocess.Popen(["iperf3", "-s", "--port", str(port)], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    except Exception as e:
        print(f"Error iniciando iperf3 en el puerto {port}: {e}")
        return None

def main():
    if host in config:
        ports = config[host]
        processes = []

        if ports:
            for port in ports:
                proc = start_iperf3(port)
                if proc:
                    processes.append((port, proc))
                    print(f"iperf3 iniciado en puerto {port} para {host}")
        else:
            print(f"No hay comandos para ejecutar en {host}.")
    else:
        print(f"Hostname {host} no reconocido. No se ejecutarán comandos.")

    # Mantener el script activo mientras los procesos se ejecutan
    try:
        while True:
            # Revisar el estado de cada proceso
            for port, proc in processes:
                if proc.poll() is not None:  # Si el proceso ha terminado
                    print(f"Proceso en puerto {port} terminó, reiniciando...")
                    new_proc = start_iperf3(port)
                    if new_proc:
                        processes[processes.index((port, proc))] = (port, new_proc)
            time.sleep(5)  # Espera antes de la siguiente verificación
    except KeyboardInterrupt:
        print("Deteniendo todos los procesos iperf3...")
        for _, proc in processes:
            proc.terminate()
        print("Script finalizado.")

if __name__ == "__main__":
    main()
