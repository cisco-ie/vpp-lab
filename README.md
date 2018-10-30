<!--
Copyright (c) 2018 Cisco Systems
Author: Steven Barth <stbarth@cisco.com>
-->

# VPP SRv6 lab with Honeycomb and Ligato
This demo includes two (equivalent) containerized SRv6 topologies orchestrated using either Honeycomb (hc2vpp) or Ligato.

![Topology Diagram](img/topology.png)

You can either follow this README and explore the readily set up lab or follow the detailed labguide to get step by step instructions
and discover the different elements including VPP, Honeycomb and Ligato one by one.

Perform the following commands prior to continuing with the labguide:
```bash
git clone --recursive https://github.com/cisco-ie/vpp-lab

./prepare.sh
```

[Follow the labguide](labguide.md)

## Prerequisites
You will need working versions of Docker & Docker Compose to run this demo as well as internet connectivity to retrieve and build containers.

You can run the labs also using Docker for Mac or Docker for Windows, for the latter you will also need the Git for Windows shell (Git Bash) to run the setup.sh script and the commands in this guide. In any case, make sure you have at least 4 GB of RAM assigned to your Docker engine (Settings -> Advanced) otherwise you may run into intermittent issues.

## Discover the environments
### All-in-one topology setup
Both demo topologies have a topology.sh script which performs the complete setup and demo instruction steps noted further below, in case you don't want to follow the labguide step-by-step.
```
./topology.sh
```

### Discover the Honeycomb (hc2vpp) topology
```
    Open a shell to a Ubuntu container:         docker-compose exec node1 bash
    Open the VPP debug CLI of a node:           docker-compose exec node1 vppctl
    Access NETCONF API with a browser:          http://localhost:9269
                                                NETCONF device:         node1:2831
                                                Username & Password:    admin
    Access the telemetry data explorer:         http://localhost:8888/sources/0/chronograf/data-explorer
    Teardown this demo:                         docker-compose down
```

### Discover the Ligato topology
```
    Open a shell to a Ubuntu container:         docker-compose exec node1 bash
    Open the VPP debug CLI of a node:           docker-compose exec node1 vppctl
    Dump the etcd datastore:                    docker-compose exec etcd etcdctl get "" --prefix
    Access ligato HTTP API with a browser:      http://localhost:9191
    Access the telemetry data explorer:         http://localhost:8888/sources/0/chronograf/data-explorer
    Teardown this demo:                         docker-compose down
```

## FYI: Detailed VPP Demo Setup (as run by setup.sh)
These are (roughly) the steps done by the setup.sh script to bring up this topology.

```
docker-compose up -d                                              # Bring up topology
docker-compose logs -f ansible                                    # Watch and wait for Ansible to complete

docker-compose exec node1 ip addr replace fd10::1/64 dev vpp      # Set Linux-side IP if not done by VPP
docker-compose exec node1 ip route add fd30::/64 via fd10::10     # Route to Container 3 via own VPP

docker-compose exec node3 ip addr replace fd30::1/64 dev vpp      # Set Linux-side IP if not done by VPP
docker-compose exec node3 ip route add fd10::/64 via fd30::30     # Route to Container 3 via own VPP

docker-compose exec node3 ping6 fd10::1                           # Ping Container 1 via VPP / SRv6
docker-compose exec node1 ping6 fd30::1                           # Ping Container 3 via VPP / SRv6
```

## FYI: Equivalent VPP Debug CLI Config
The Ansible playbooks under hc2vpp and ligato result in a configuration that is roughly equivaltent to the debug CLI commands below (example given for node 1).

```
create host-interface name eth0 hw-addr 00:00:00:00:12:10
create host-interface name eth1 hw-addr 00:00:00:00:13:10
create tap hw-addr 00:00:00:00:10:10 host-ip6-addr fd10::1/64 host-if-name vpp

set interface state host-eth0 up
set interface state host-eth1 up
set interface state tapcli-0 up

set interface ip address host-eth0 fd12::10/64
set interface ip address host-eth1 fd13::10/64
set interface ip address tapcli-0 fd10::10/64
```

```
sr localsid address fd11::100 behavior end
sr localsid address fd11::101 behavior end.dx6 tapcli-0 fd10::1
```

```
ip route add fd22::/64 via host-eth0
ip route add fd33::/64 via host-eth1

set ip6 neighbor host-eth0 fd22::100 00:00:00:00:12:20
set ip6 neighbor host-eth0 fd22::101 00:00:00:00:12:20
set ip6 neighbor host-eth1 fd33::100 00:00:00:00:13:30
set ip6 neighbor host-eth1 fd33::101 00:00:00:00:13:30
```

```
sr policy add bsid fd11::13 next fd33::101 encap
sr steer l3 fd30::1/128 via bsid fd11::13
```
