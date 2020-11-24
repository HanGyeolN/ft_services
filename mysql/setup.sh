#!/bin/sh
./build_mysql.sh
kubectl apply -f configmap-mysql.yaml
kubectl apply -f pv-mysql.yaml
kubectl apply -f pvc-mysql.yaml
kubectl apply -f deployment-mysql.yaml
kubectl apply -f service-mysql.yaml
