#!/bin/sh
kubectl delete deploy phpmyadmin -n ft-services
kubectl delete service phpmyadmin -n ft-services
