#!/bin/sh
export SERVICE=grafana
kubectl delete deployment $SERVICE -n ft-services
kubectl delete service $SERVICE -n ft-services
unset SERVICE
