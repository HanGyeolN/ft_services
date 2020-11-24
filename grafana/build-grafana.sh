#!/bin/bash
docker build -t grafana .
docker tag grafana docker-registry:5001/grafana
docker push docker-registry:5001/grafana
