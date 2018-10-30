#!/bin/bash
docker-compose -f hc2vpp/docker-compose.yaml pull
docker-compose -f hc2vpp/docker-compose.yaml build

docker-compose -f ligato/docker-compose.yaml pull
docker-compose -f ligato/docker-compose.yaml build

