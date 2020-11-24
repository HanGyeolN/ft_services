# Create Certificates
mkdir certs
openssl req -newkey rsa:2048 -x509 -sha256 -days 365 -nodes -out \
			./certs/registry.crt -keyout ./certs/registry.key -subj \
			"/C=KR/ST=SEOUL/L=GANGNAM/OU=42/CN=docker-registry"

# Server Mount
sudo cp -r ./certs /node-registry-certs

# Client Setting
sudo cp ./certs/registry.crt /usr/share/ca-certificates/
sudo chmod 666 /etc/ca-certificates.conf
echo registry.crt >> /etc/ca-certificates.conf
sudo update-ca-certificates
sudo service docker restart
