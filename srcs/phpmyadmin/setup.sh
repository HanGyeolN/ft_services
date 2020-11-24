#!/bin/sh
./build_phpmyadmin.sh
kubectl apply -f ./deployment_phpmyadmin.yaml
kubectl apply -f ./service_phpmyadmin.yaml
