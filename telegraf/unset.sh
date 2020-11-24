#!/bin/sh
export SERVICE=monitoring
kubectl delete clusterrolebinding monitoring -n monitoring
kubectl delete clusterrole monitoring
kubectl delete serviceaccount sa
kubectl delete daemonset telegraf -n monitoring
unset SERVICE
