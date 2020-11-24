docker build -t mysql .
docker tag mysql docker-registry:5001/mysql
docker push docker-registry:5001/mysql
