FROM alpine

RUN apk update
RUN apk add vsftpd
RUN apk add openssl

RUN openssl req -newkey rsa:2048 -x509 -sha256 -days 365 -nodes -out /etc/vsftpd/example.crt -keyout /etc/vsftpd/example.key -subj "/C=KR/ST=SEOUL/L=SEOUL/OU=42/CN=52.78.194.201"
RUN openssl x509 -in /etc/vsftpd/example.crt -out /etc/vsftpd/example.pem

RUN adduser -D ftpuser
RUN passwd -d ftpuser '1234'

ADD srcs/vsftpd.conf /etc/vsftpd/vsftpd.conf

EXPOSE 20
EXPOSE 21
EXPOSE 30020
EXPOSE 30021

ADD srcs/start.sh /start.sh
ENTRYPOINT ["/start.sh"]
# ENTRYPOINT ["vsftpd", "/etc/vsftpd/vsftpd.conf"]
# CMD ["sh", "-c", "tail -f /dev/null"]
