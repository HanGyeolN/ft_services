#!/bin/sh

export WORK_DIR=/home/ubuntu/ft-services/srcs

kubectl apply -f $WORK_DIR/namespace.yaml

cd $WORK_DIR/metallb
./install.sh

cd $WORK_DIR/dashboard
./install.sh

cd $WORK_DIR/mysql
./setup.sh

cd $WORK_DIR/phpmyadmin
./setup.sh

cd $WORK_DIR/wordpress
./setup.sh

cd $WORK_DIR/nginx
./setup.sh

cd $WORK_DIR/ftps
./setup.sh

cd $WORK_DIR/influxdb
./setup.sh

cd $WORK_DIR/telegraf
./setup.sh

cd $WORK_DIR/grafana
./setup.sh
