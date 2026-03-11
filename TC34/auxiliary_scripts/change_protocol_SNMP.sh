#!/bin/bash

NAMESPACE="10-ceos-tc33"

for i in {1..10}; do
    SERVICE="service-r$i"
    echo "Patching $SERVICE ..."
    kubectl patch svc "$SERVICE" -n "$NAMESPACE" \
        --type='json' \
        -p='[{"op":"replace","path":"/spec/ports/0/protocol","value":"UDP"}]'
done
