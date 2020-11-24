#!/bin/sh
export NAME=grafana
./build-$NAME.sh
kubectl apply -f deployment-$NAME.yaml
kubectl apply -f service-$NAME.yaml
unset NAME
