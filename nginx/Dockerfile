FROM alpine
MAINTAINER hna <hna@student.42seoul.kr>

RUN apk update
RUN apk add nginx
RUN apk add openssl
RUN apk add openssh

RUN mkdir /run/nginx
RUN openssl req -newkey rsa:2048 -x509 -sha256 -days 3650 -nodes -out \
			/etc/nginx/example.crt -keyout /etc/nginx/example.key -subj \
			"/C=KR/ST=SEOUL/L=SEOUL/OU=42/CN=nginx.com"; nginx -t;
RUN openssl x509 -in /etc/nginx/example.crt -out /etc/nginx/example.pem
RUN adduser -D -g 'www' www
RUN mkdir /www
RUN chown -R www:www /var/lib/nginx
RUN chown -R www:www /www
RUN passwd root -d 1234
RUN ssh-keygen -A

ADD srcs/nginx.conf /etc/nginx/nginx.conf
ADD srcs/index.html /www/index.html
ADD srcs/index443.html /www/index443.html
ADD srcs/favicon.ico /favicon.ico
ADD srcs/sshd_config /etc/ssh/sshd_config

EXPOSE 80
EXPOSE 443
EXPOSE 22

# CMD nginx & /usr/sbin/sshd
CMD ["sh", "-c", "tail -f /dev/null"]
