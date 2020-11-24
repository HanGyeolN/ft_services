#!/bin/sh
./build-nginx.sh
kubectl apply -f deployment-nginx.yaml
kubectl apply -f service-nginx.yaml
