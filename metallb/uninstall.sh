kubectl delete namespace metallb-system --force

kubectl get namespace metallb-system -o json > logging.json
sed 's/"kubernetes"//g' logging.json > new_logging.json
kubectl replace --raw "/api/v1/namespaces/metallb-system/finalize" -f ./new_logging.json
rm ./logging.json ./new_logging.json
