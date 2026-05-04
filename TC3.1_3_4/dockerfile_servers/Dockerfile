
FROM ubuntu:22.04

WORKDIR /across
LABEL maintainer="mario.sanz@upm.es"

ENV PASSWORD=1234

RUN apt-get update \
	&& apt-get install -y --no-install-recommends net-tools iproute2 sudo \
	wget curl dpkg nano traceroute iputils-ping nmap\
	openssh-server openssh-client snmp iperf3 \
	python3 python3-pip

RUN mkdir -p /run/sshd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

RUN useradd -m -s /bin/bash across
RUN echo "across:${PASSWORD}" | chpasswd \
	&& usermod -aG sudo across \
	&& echo "across ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

COPY routes /home/across/routes
COPY load_routes.sh /home/across/load_routes.sh

EXPOSE 22
