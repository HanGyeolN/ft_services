#!/bin/bash
docker build -t telegraf .
docker tag telegraf docker-registry:5001/telegraf
docker push docker-registry:5001/telegraf
