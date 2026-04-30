#!/bin/bash

kubectl -n across-tc34 exec -it server1 -- service ssh start
kubectl -n across-tc34 exec -it server2 -- service ssh start
kubectl -n across-tc34 exec -it server3 -- service ssh start

kubectl -n across-tc34 exec -it probe1 -- service ssh start
kubectl -n across-tc34 exec -it probe5 -- service ssh start
kubectl -n across-tc34 exec -it probe7 -- service ssh start

kubectl -n across-tc34 exec -it server1 -- bash -c ". /home/across/load_routes.sh"
kubectl -n across-tc34 exec -it server2 -- bash -c ". /home/across/load_routes.sh"
kubectl -n across-tc34 exec -it server3 -- bash -c ". /home/across/load_routes.sh"

kubectl -n across-tc34 exec -it probe1 -- bash -c ". /home/across/load_routes.sh"
kubectl -n across-tc34 exec -it probe5 -- bash -c ". /home/across/load_routes.sh"
kubectl -n across-tc34 exec -it probe7 -- bash -c ". /home/across/load_routes.sh"
