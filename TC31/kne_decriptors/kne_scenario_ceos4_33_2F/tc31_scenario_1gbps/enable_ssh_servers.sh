#!/bin/bash

kubectl -n across-tc31 exec -it server1 -- service ssh start
kubectl -n across-tc31 exec -it server2 -- service ssh start
kubectl -n across-tc31 exec -it server3 -- service ssh start

kubectl -n across-tc31 exec -it server1 -- bash -c ". /home/across/load_routes.sh"
kubectl -n across-tc31 exec -it server2 -- bash -c ". /home/across/load_routes.sh"
kubectl -n across-tc31 exec -it server3 -- bash -c ". /home/across/load_routes.sh"
