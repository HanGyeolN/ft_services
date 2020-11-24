#!/bin/sh
kubectl delete deployment mysql -n ft-services
kubectl delete service mysql -n ft-services
kubectl delete configmap cm-mysql -n ft-services
kubectl delete pvc pvc-mysql -n ft-services
kubectl delete pv pv-mysql
