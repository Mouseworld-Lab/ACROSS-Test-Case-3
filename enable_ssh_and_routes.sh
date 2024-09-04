#!/bin/bash

kubectl -n 13-csr exec -it server1 -- service ssh start
kubectl -n 13-csr exec -it server2 -- service ssh start
kubectl -n 13-csr exec -it server3 -- service ssh start
kubectl -n 13-csr exec -it server4 -- service ssh start
kubectl -n 13-csr exec -it server5 -- service ssh start

kubectl -n 13-csr exec -it client1 -- service ssh start
kubectl -n 13-csr exec -it client2 -- service ssh start
kubectl -n 13-csr exec -it client3 -- service ssh start
kubectl -n 13-csr exec -it client4 -- service ssh start
kubectl -n 13-csr exec -it client5 -- service ssh start

kubectl -n 13-csr exec -it server1 -- bash -c ". /home/across/load_routes.sh"
kubectl -n 13-csr exec -it server2 -- bash -c ". /home/across/load_routes.sh"
kubectl -n 13-csr exec -it server3 -- bash -c ". /home/across/load_routes.sh"
kubectl -n 13-csr exec -it server4 -- bash -c ". /home/across/load_routes.sh"
kubectl -n 13-csr exec -it server5 -- bash -c ". /home/across/load_routes.sh"

kubectl -n 13-csr exec -it client1 -- bash -c ". /home/across/load_routes.sh"
kubectl -n 13-csr exec -it client2 -- bash -c ". /home/across/load_routes.sh"
kubectl -n 13-csr exec -it client3 -- bash -c ". /home/across/load_routes.sh"
kubectl -n 13-csr exec -it client4 -- bash -c ". /home/across/load_routes.sh"
kubectl -n 13-csr exec -it client5 -- bash -c ". /home/across/load_routes.sh"
