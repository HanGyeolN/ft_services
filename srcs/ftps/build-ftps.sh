docker build -t ftps .
docker tag ftps docker-registry:5001/ftps
docker push docker-registry:5001/ftps
