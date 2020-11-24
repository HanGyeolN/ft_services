#!/bin/sh
export SERVICE=ftps
kubectl delete deployment $SERVICE -n ft-services
kubectl delete service $SERVICE -n ft-services
kubectl delete pvc pvc-$SERVICE -n ft-services
kubectl delete pv pv-$SERVICE
unset SERVICE
