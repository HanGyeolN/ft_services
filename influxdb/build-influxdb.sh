#!/bin/bash
docker build -t influxdb .
docker tag influxdb docker-registry:5001/influxdb
docker push docker-registry:5001/influxdb
