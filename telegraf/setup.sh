#!/bin/sh
export NAME=telegraf
./build-$NAME.sh
kubectl apply -f namespace-$NAME.yaml
kubectl apply -f clusterrole-$NAME.yaml
kubectl apply -f serviceaccount-$NAME.yaml
kubectl apply -f clusterrolebinding-$NAME.yaml
kubectl apply -f daemonset-$NAME.yaml
unset NAME
