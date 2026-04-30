#!/bin/bash

# Test 1 - Ancho de banda bajo
curl "http://138.4.21.168:9579/probe?target=10.1.3.10&bitrate=10M&period=60s"
sleep 70  # Espera 70 segundos

# Test 2 - Ancho de banda alto
curl "http://138.4.21.168:9579/probe?target=10.1.3.10&bitrate=100M&period=60s"
sleep 70  # Espera 70 segundos

# Test 3 - UDP
curl "http://138.4.21.168:9579/probe?target=10.1.3.10&udp_mode=true&bitrate=50M&period=60s"
