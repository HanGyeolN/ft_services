export CONNECT_IP=13.125.60.160
# 13.125.60.160
echo "put -r certs" | sftp -i LightsailDefaultKey-ap-northeast-2.pem ubuntu@$CONNECT_IP
ssh -i LightsailDefaultKey-ap-northeast-2.pem ubuntu@$CONNECT_IP 'sudo cp ./certs/registry.crt /usr/share/ca-certificates/ ; exit'
echo 'echo registry.crt >> /etc/ca-certificates.conf; exit' | ssh -i LightsailDefaultKey-ap-northeast-2.pem ubuntu@$CONNECT_IP 'sudo su'
ssh -i LightsailDefaultKey-ap-northeast-2.pem ubuntu@$CONNECT_IP 'sudo update-ca-certificates; sudo service docker restart'
unset CONNECT_IP
