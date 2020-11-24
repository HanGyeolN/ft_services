#!/bin/sh
kubectl delete deployment dashboard-metrics-scraper -n kubernetes-dashboard
kubectl delete service dashboard-metrics-scraper -n kubernetes-dashboard
kubectl delete deployment kubernetes-dashboard -n kubernetes-dashboard
kubectl delete service kubernetes-dashboard -n kubernetes-dashboard
kubectl delete serviceaccount --all -n kubernetes-dashboard
kubectl delete clusterrolebinding kubernetes-dashboard
kubectl delete clusterrole kubernetes-dashboard
