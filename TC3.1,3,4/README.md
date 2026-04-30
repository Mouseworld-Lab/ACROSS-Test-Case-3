# ACROSS

## Overview

This repository contains the **ACROSS Network Digital Twin (NDT)** platform used to generate realistic network datasets for training machine learning and AI models focused on predictive and autonomous network management.

The platform is built on a **Kubernetes cluster** using **KNE (Kubernetes Network Emulation)** to deploy network topologies composed of **Arista cEOS routers running in containers**. These emulated networks reproduce realistic operational conditions where specific configurations, traffic flows, congestion scenarios, degradations, and failure events can be systematically introduced.

Monitoring probes deployed within the NDT collect detailed telemetry and performance metrics from the network. The collected data is used to build datasets aimed at training models capable of **anticipating congestion, QoS degradation, and potential SLA violations**.

The ACROSS NDT supports the experimental scenarios developed in **TC3.1, TC3.3, and TC3.4**, where the main objective is the **generation of realistic and reproducible datasets**. Both the monitoring mechanisms and the resulting datasets are designed to be directly applicable to real network deployments, enabling the transition from controlled emulated environments to physical infrastructures.

This repository includes the **topology definitions, deployment descriptors, and supporting tools** required to reproduce the NDT scenarios and generate the datasets used in the ACROSS experiments.

## Network Topology

An example of how to create a topology using the `new_scenario_ceos_tc.yaml` descriptor is shown below.

![Topology](images/ACROSS_TC3.x_nuevos_links.drawio_v3.png)

---

# Scenarios

The following scenarios are implemented in this repository.

## TC3.1 — Anticipatory Detection, Analysis & Prevention of Congestion Problems
This sub-test evaluates the network’s ability to maintain quality service by ensuring the availability of required resources in multiple stakeholder net- works. It is based on predefined values such as latency, jitter, and errors. If potential issues are predicted, the network is reconfigured to avoid service degradation.

![Topology](images/TC31_global.PNG)

## TC3.3 — Smart QoS-aware Zero-Touch Traffic Engineering
This sub-test focuses on Quality of Service (QoS) preservation in multiple stakeholder networks. It relies on predefined values for latency, jitter, and errors to predict and reconfigure the network for service optimization. An emulated network scenario with data and control plane links is employed, and QoS degradation is emulated, including error-related issues such as con- nection timeouts.

![Topology](images/TC33_global.PNG)

## TC3.4 — Intelligent Zero-Touch SLA Preservation
This sub-test emphasizes the preservation of Service Level Agreements (SLAs) in multiple stakeholder networks. Using predefined values, including latency, jitter, and errors, SLAs are measured both end-to-end and per-hop. Predictive reconfiguration of the network is performed to ensure SLA preser- vation. Similar to previous sub-tests, it employs an emulated network sce- nario and emulates SLA violations, such as exceeding acceptable downtime specified in the SLA

![Topology](images/TC34_global.PNG)

---

# Outcomes

The datasets generated for each scenario are publicly available.

### TC3.1 — Anticipatory Detection, Analysis & Prevention of Congestion Problems
https://zenodo.org/records/17255272

### TC3.3 — Smart QoS-aware Zero-Touch Traffic Engineering
https://zenodo.org/records/17255307

### TC3.4 — Intelligent Zero-Touch SLA Preservation
https://zenodo.org/records/17255327

# ACROSS Outcomes Demo-Videos for each TC

### TC3.1 — Anticipatory Detection, Analysis & Prevention of Congestion Problems

[![TC3.1 Demo](https://img.youtube.com/vi/5iaajOp_w30/maxresdefault.jpg)](https://www.youtube.com/watch?v=5iaajOp_w30)

---

### TC3.3 — Smart QoS-aware Zero-Touch Traffic Engineering

[![TC3.3 Demo](https://img.youtube.com/vi/CEMg2BINd5k/maxresdefault.jpg)](https://www.youtube.com/watch?v=CEMg2BINd5k)

---

### TC3.4 — Intelligent Zero-Touch SLA Preservation

[![TC3.4 Demo](https://img.youtube.com/vi/ngyVykRuHrk/maxresdefault.jpg)](https://www.youtube.com/watch?v=ngyVykRuHrk)

---

# Example of Use

## 1. Create the 10-router topology

```bash
kne create kne/examples/TC3.X_new_scenario/new_scenario.yaml

## 2. Delete the scenario:
```bash
kne delete  kne/examples/TC3.X_new_scenario/new_scenario.yamlcisco/13csr_RSTI/13csr.yaml
```

## 3. See the status of the pods:
```bash
kubectl get pods -A -o wide -w
```

Once the topology has been successfully deloyed, the device created with vrnetlab can be accessed with the default credentials, corresponding to the user and password, "vrnetlab" and "VR-netlab9" respectively and its external IP address.

## 4. Identify the External-IP: 

```bash
root@k8-controller:~# kubectl get services -n 10-ceos-v3
NAME                 TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
service-broker       LoadBalancer   10.99.49.219     172.18.0.62   22/TCP         110s
service-probe1       LoadBalancer   10.101.49.211    172.18.0.55   22/TCP         113s
service-probe2       LoadBalancer   10.98.72.210     172.18.0.54   22/TCP         114s
service-probe3       LoadBalancer   10.110.142.86    172.18.0.63   22/TCP         109s
service-probe4       LoadBalancer   10.111.152.160   172.18.0.51   22/TCP         114s
service-probe5       LoadBalancer   10.98.165.90     172.18.0.60   22/TCP         111s
service-probe6       LoadBalancer   10.96.47.14      172.18.0.56   22/TCP         113s
service-probe7       LoadBalancer   10.99.23.92      172.18.0.53   22/TCP         114s
service-probe8       LoadBalancer   10.97.55.219     172.18.0.61   22/TCP         111s
service-probe9       LoadBalancer   10.108.81.118    172.18.0.52   22/TCP         114s
service-r1           LoadBalancer   10.109.125.207   172.18.0.71   22:30797/TCP   59s
service-r10          LoadBalancer   10.105.138.235   172.18.0.65   22:32389/TCP   81s
service-r2           LoadBalancer   10.96.83.39      172.18.0.64   22:30782/TCP   83s
service-r3           LoadBalancer   10.104.68.93     172.18.0.69   22:30835/TCP   60s
service-r4           LoadBalancer   10.97.195.1      172.18.0.68   22:31510/TCP   64s
service-r5           LoadBalancer   10.107.191.61    172.18.0.66   22:32620/TCP   72s
service-r6           LoadBalancer   10.96.216.202    172.18.0.73   22:30816/TCP   50s
service-r7           LoadBalancer   10.108.117.101   172.18.0.70   22:31178/TCP   59s
service-r8           LoadBalancer   10.96.162.175    172.18.0.67   22:31135/TCP   69s
service-r9           LoadBalancer   10.98.163.118    172.18.0.72   22:31344/TCP   50s
service-routermgmt   LoadBalancer   10.97.60.236     172.18.0.57   22:31856/TCP   113s
service-server1      LoadBalancer   10.108.172.120   172.18.0.59   22/TCP         112s
service-server2      LoadBalancer   10.108.113.45    172.18.0.58   22/TCP         112s
service-server3      LoadBalancer   10.102.35.134    172.18.0.50   22/TCP         114s
```

## 5. Access to the router r1:

```bash
ssh admin@172.18.0.71
Password: admin
```

## 6.  Start ssh in the server and client containers

```bash
sh enable_ssh_clients_and_servers.sh
```

## 7.  Access to the probes (ej. probe1):

```bash
ssh across@172.18.0.55
Password: 1234
```

