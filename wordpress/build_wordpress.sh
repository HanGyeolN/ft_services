docker build -t wordpress .
docker tag wordpress docker-registry:5001/wordpress
docker push docker-registry:5001/wordpress
