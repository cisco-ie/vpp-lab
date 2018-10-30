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

FROM ubuntu:18.04

ARG VPP=18.10-release
ARG HONEYCOMB=1.18.10-RC2~16

ARG VPP_BASE=https://nexus.fd.io/content/repositories/fd.io.stable.1810.ubuntu.bionic.main/io/fd/vpp/
ARG HONEYCOMB_BASE=https://nexus.fd.io/content/repositories/fd.io.stable.1810.ubuntu.xenial.main/io/fd/hc2vpp/honeycomb/

ARG PKG_VPP=${VPP_BASE}/vpp/${VPP}_amd64/vpp-${VPP}_amd64-deb.deb
ARG PKG_VPP_LIB=${VPP_BASE}/vpp-lib/${VPP}_amd64/vpp-lib-${VPP}_amd64-deb.deb
ARG PKG_VPP_PLUGINS=${VPP_BASE}/vpp-plugins/${VPP}_amd64/vpp-plugins-${VPP}_amd64-deb.deb
ARG PKG_HONEYCOMB=${HONEYCOMB_BASE}/${HONEYCOMB}_all/honeycomb-${HONEYCOMB}_all-deb.deb

RUN apt-get update && apt-get install -y \
    # Utils
    iproute2 iputils-ping net-tools vim-tiny jshon telnet curl wget ethtool \
    # VPP package dependencies
    libnuma1 libssl1.0.0 libmbedcrypto1 libmbedtls10 libmbedx509-0 \
    # Honeycomb package dependencies
    openjdk-8-jre-headless \
# Install packages
&& mkdir /tmp/deb && cd /tmp/deb \
&& echo $PKG_VPP \\n $PKG_VPP_LIB \\n $PKG_VPP_PLUGINS \\n $PKG_HONEYCOMB > urls \
&& wget -i urls && dpkg --ignore-depends=vpp --ignore-depends=vpp-plugins -i *.deb \
# Reduce image size
&& cd / && rm -rf /var/lib/apt/lists/* /tmp/deb

COPY entrypoint.sh /
CMD ["/entrypoint.sh"] 
