FROM alpine:latest
MAINTAINER hna <hna@student.42seoul.kr>

# https://wiki.alpinelinux.org/wiki/WordPress
RUN apk update

RUN adduser -D -g 'www' www
RUN mkdir /www
RUN mkdir -p /var/lib/nginx
RUN chown -R www:www /var/lib/nginx
RUN chown -R www:www /www

## nginx with php
RUN apk add php7-common php7-iconv php7-json php7-gd php7-curl \
    php7-xml php7-mysqli php7-imap php7-cgi fcgi php7-pdo php7-pdo_mysql php7-soap \
    php7-xmlrpc php7-posix php7-mcrypt php7-gettext php7-ldap php7-ctype php7-dom php7-fpm \
    php7-exif php7-fileinfo php7-mbstring php7-imagick php7-zip

RUN apk add nginx
RUN apk add openssl
RUN mkdir /run/nginx
RUN openssl req -newkey rsa:2048 -x509 -sha256 -days 3650 -nodes -out \
			/etc/nginx/example.crt -keyout /etc/nginx/example.key -subj \
			"/C=KR/ST=SEOUL/L=SEOUL/OU=42/CN=52.78.194.201"; nginx -t;

## wordpress
RUN mkdir -p /usr/share/webapps/
WORKDIR /usr/share/webapps/
RUN wget https://wordpress.org/wordpress-5.5.tar.gz
RUN mv wordpress-5.5.tar.gz latest.tar.gz
RUN tar -xzvf latest.tar.gz

RUN mv wordpress/* /www
ADD srcs/wp-config.php /www/wp-config.php
#ADD srcs/wp-config.php /usr/share/webapps/wordpress/wp-config.php
RUN find . -type d -exec chmod 777 {} \;
RUN find . -type f -exec chmod 777 {} \;
#RUN rm latest.tar.gz

WORKDIR /
ADD srcs/nginx.conf /etc/nginx/nginx.conf
ADD srcs/env.sh /env.sh
RUN chmod +x env.sh
RUN source env.sh


EXPOSE 5050

# CMD ["/bin/sh", "-c", "while true; do echo hello; sleep 10;done"]
CMD php-fpm7 && nginx -g "daemon off;"
