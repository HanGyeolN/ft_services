docker build -t nginx .
docker tag nginx docker-registry:5001/nginx
docker push docker-registry:5001/nginx
