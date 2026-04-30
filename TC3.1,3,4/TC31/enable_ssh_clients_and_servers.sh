#!/bin/bash

kubectl -n 10-ceos-v3 exec -it server1 -- service ssh start
kubectl -n 10-ceos-v3 exec -it server2 -- service ssh start
kubectl -n 10-ceos-v3 exec -it server3 -- service ssh start

kubectl -n 10-ceos-v3 exec -it broker -- service ssh start

kubectl -n 10-ceos-v3 exec -it probe1 -- service ssh start
kubectl -n 10-ceos-v3 exec -it probe2 -- service ssh start
kubectl -n 10-ceos-v3 exec -it probe3 -- service ssh start
kubectl -n 10-ceos-v3 exec -it probe4 -- service ssh start
kubectl -n 10-ceos-v3 exec -it probe5 -- service ssh start
kubectl -n 10-ceos-v3 exec -it probe6 -- service ssh start
kubectl -n 10-ceos-v3 exec -it probe7 -- service ssh start
kubectl -n 10-ceos-v3 exec -it probe8 -- service ssh start
kubectl -n 10-ceos-v3 exec -it probe9 -- service ssh start

kubectl -n 10-ceos-v3 exec -it server1 -- bash -c ". /home/across/load_routes.sh"
kubectl -n 10-ceos-v3 exec -it server2 -- bash -c ". /home/across/load_routes.sh"
kubectl -n 10-ceos-v3 exec -it server3 -- bash -c ". /home/across/load_routes.sh"

kubectl -n 10-ceos-v3 exec -it broker -- bash -c ". /home/across/load_routes.sh"

kubectl -n 10-ceos-v3 exec -it probe1 -- bash -c ". /home/across/load_routes.sh"
kubectl -n 10-ceos-v3 exec -it probe2 -- bash -c ". /home/across/load_routes.sh"
kubectl -n 10-ceos-v3 exec -it probe3 -- bash -c ". /home/across/load_routes.sh"
kubectl -n 10-ceos-v3 exec -it probe4 -- bash -c ". /home/across/load_routes.sh"
kubectl -n 10-ceos-v3 exec -it probe5 -- bash -c ". /home/across/load_routes.sh"
kubectl -n 10-ceos-v3 exec -it probe6 -- bash -c ". /home/across/load_routes.sh"
kubectl -n 10-ceos-v3 exec -it probe7 -- bash -c ". /home/across/load_routes.sh"
kubectl -n 10-ceos-v3 exec -it probe8 -- bash -c ". /home/across/load_routes.sh"
kubectl -n 10-ceos-v3 exec -it probe9 -- bash -c ". /home/across/load_routes.sh"
