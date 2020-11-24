#!/bin/sh
kubectl delete deployment nginx -n ft-services
kubectl delete service nginx -n ft-services
