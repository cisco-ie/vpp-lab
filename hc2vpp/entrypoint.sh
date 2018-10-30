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

mknod /dev/vhost-net c 10 238

grep -q statseg /etc/vpp/startup.conf || echo -e "statseg {\ndefault\n}\nplugins {\nplugin dpdk_plugin.so { disable }\n}\n" >> /etc/vpp/startup.conf
ulimit -c unlimited

vpp -c /etc/vpp/startup.conf &
while [ ! -S "/run/vpp/stats.sock" -o ! -S "/run/vpp-api.sock" ]; do sleep 1; done

/opt/honeycomb/honeycomb-start

while true; do
    vpp_prometheus_export /net /if /err >>/var/log/vpp_prometheus_export 2>&1
    sleep 5
done