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

echo Waiting for etcd and nodes to start...
wait-for-it etcd:2379 -t 300
wait-for-it node1:9191 -t 300
wait-for-it node2:9191 -t 300
wait-for-it node3:9191 -t 300

if [ "$#" = 0 ]; then
    for playbook in /*.yaml; do
        ansible-playbook $playbook
    done
else
    for playbook in "$@"; do
        ansible-playbook $playbook
    done
fi

