export TARGET_NAMESPACE=monitoring

kubectl get namespace $TARGET_NAMESPACE -o json > logging.json
sed 's/"kubernetes"//g' logging.json > new_logging.json
kubectl replace --raw "/api/v1/namespaces/$TARGET_NAMESPACE/finalize" -f ./new_logging.json
rm ./logging.json ./new_logging.json
unset TARGET_NAMESPACE
