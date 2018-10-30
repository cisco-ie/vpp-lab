#!/bin/bash
#
# Copyright (c) 2018 Cisco Systems
#
# Author: Steven Barth <stbarth@cisco.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

echo Bringing up containers...
docker-compose up -d                                # Bring up topology

echo Waiting for Ansible to complete...
docker-compose logs -f ansible

echo Configuring Ubuntu networking...
docker-compose exec node1 ip addr replace fd10::1/64 dev vpp      # Set Linux-side IP if not done by VPP
docker-compose exec node1 ip route add fd30::/64 via fd10::10     # Route to Container 3 via own VPP
docker-compose exec node3 ip addr replace fd30::1/64 dev vpp      # Set Linux-side IP if not done by VPP
docker-compose exec node3 ip route add fd10::/64 via fd30::30     # Route to Container 3 via own VPP

echo Running pings between Node 1 and Node 3 over SRv6 tunnel
for i in `seq 1 10`; do
        docker-compose exec node1 ping6 -c 1 fd30::1
        docker-compose exec node3 ping6 -c 1 fd10::1
done


cat <<EOF


All done. You can do the following to explore this setup further:
    Open a shell to a Ubuntu container:         docker-compose exec node1 bash
    Open the VPP debug CLI of a node:           docker-compose exec node1 vppctl
    Dump the etcd datastore:                    docker-compose exec etcd etcdctl get "" --prefix
    Access ligato HTTP API with a browser:      http://localhost:9191
    Access the telemetry data explorer:         http://localhost:8888/sources/0/chronograf/data-explorer
    Teardown this demo:                         docker-compose down
EOF
