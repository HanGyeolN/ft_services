#!/bin/sh
export NAME=wordpress
./build_$NAME.sh
kubectl apply -f configmap-$NAME.yaml
kubectl apply -f pv-$NAME.yaml
kubectl apply -f pvc-$NAME.yaml
kubectl apply -f deployment-$NAME.yaml
kubectl apply -f service-$NAME.yaml
unset NAME
