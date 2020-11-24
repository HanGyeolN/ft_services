#!/bin/sh

export WORK_DIR=/home/ubuntu/ft-services/srcs

$WORK_DIR/grafana/unset.sh
$WORK_DIR/telegraf/unset.sh
$WORK_DIR/influxdb/unset.sh
$WORK_DIR/ftps/unset.sh
$WORK_DIR/nginx/unset.sh
$WORK_DIR/wordpress/unset.sh
$WORK_DIR/phpmyadmin/unset.sh
$WORK_DIR/mysql/unset.sh
$WORK_DIR/dashboard/unset.sh
$WORK_DIR/metallb/unset.sh

kubectl delete serviceaccount --all -n monitoring
kubectl delete serviceaccount --all -n ft-services

kubectl delete namespace kubernetes-dashboard
kubectl delete namespace metallb-system
kubectl delete namespace ft-services
kubectl delete namespace monitoring
