#!/bin/sh
docker build -t phpmyadmin .
docker tag phpmyadmin docker-registry:5001/phpmyadmin
docker push docker-registry:5001/phpmyadmin
