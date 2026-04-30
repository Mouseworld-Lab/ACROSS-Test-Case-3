from prometheus_client import start_http_server, Gauge
from confluent_kafka import Consumer
import json
import time

# =========================================
# CONFIGURACIÓN A MANO
KAFKA_BROKER = "138.4.21.186:9092"   # <-- pon aquí tu broker
KAFKA_TOPIC = "ml_tc31_output"       # <-- pon aquí tu topic
KAFKA_GROUP = "ml-metrics-exporter"  # nombre del consumer group
EXPORTER_PORT = 8000                 # puerto para exponer métricas
# =========================================

# Métrica de predicciones con etiqueta "link"
prediction_gauge = Gauge("ml_tc31_prediction", "Prediction by router", ["host"])

# Configuración del consumidor Kafka
conf = {
    'bootstrap.servers': KAFKA_BROKER,
    'group.id': KAFKA_GROUP,
    'auto.offset.reset': 'latest'
}
consumer = Consumer(conf)
consumer.subscribe([KAFKA_TOPIC])

# Servidor Prometheus
start_http_server(EXPORTER_PORT)
print(f"Exporter escuchando en :{EXPORTER_PORT}/metrics ...")
print(f"Conectando a broker {KAFKA_BROKER}, topic {KAFKA_TOPIC}")

try:
    while True:
        msg = consumer.poll(1.0)

        if msg is None:
            continue
        if msg.error():
            print(f"Error: {msg.error()}")
            continue

        try:
            payload = msg.value().decode("utf-8")
            print(f"I read this message from the topic: {payload}")

            data = json.loads(payload)

            # Read fields from JSON
            host = data.get("Host Name")
            prediction = data.get("Prediction")

            if host is not None and prediction is not None:
                # Convert host to a valid label
                prediction_gauge.labels(host=host).set(prediction)

                print(f"Sent to Prometheus → host={host}, prediction={prediction}")

        except Exception as e:
            print(f"Error processing message: {e}")
            time.sleep(1)

except KeyboardInterrupt:
    print("\nInterrupt received, closing consumer...")
    consumer.close()
    print("Consumer closed. Exiting.")
