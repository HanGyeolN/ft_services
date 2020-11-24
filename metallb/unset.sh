#!/bin/sh
kubectl delete deployment controller -n metallb-system --force
kubectl delete daemonset speaker -n metallb-system --force
kubectl delete clusterrolebinding metallb-system:controller
kubectl delete clusterrolebinding metallb-system:speaker
kubectl delete clusterrole metallb-system:controller
kubectl delete clusterrole metallb-system:speaker
kubectl delete serviceaccount --all -n  metallb-system


