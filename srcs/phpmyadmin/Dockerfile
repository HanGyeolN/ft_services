FROM alpine:latest
MAINTAINER hna <hna@student.42seoul.kr>

# https://wiki.alpinelinux.org/wiki/PhpMyAdmin
RUN apk update
RUN apk add openrc

RUN adduser -D -g 'www' www
RUN mkdir /www
RUN mkdir -p /var/lib/nginx
RUN chown -R www:www /var/lib/nginx
RUN chown -R www:www /www

## nginx
RUN apk add nginx
RUN apk add openssl
RUN mkdir /run/nginx
RUN openssl req -newkey rsa:2048 -x509 -sha256 -days 3650 -nodes -out \
			/etc/nginx/example.crt -keyout /etc/nginx/example.key -subj \
			"/C=KR/ST=SEOUL/L=SEOUL/OU=42/CN=52.78.194.201"; nginx -t;


## phpmyadmin
RUN apk add php7-fpm php7-mcrypt php7-soap php7-openssl php7-gmp php7-pdo_odbc php7-json php7-dom php7-pdo php7-zip php7-mysqli php7-sqlite3 php7-apcu php7-pdo_pgsql php7-bcmath php7-gd php7-odbc php7-pdo_mysql php7-pdo_sqlite php7-gettext php7-xmlreader php7-xmlrpc php7-bz2 php7-iconv php7-pdo_dblib php7-curl php7-ctype php7-session php7-common php7-gd php7-xml php7-imap php7-cgi fcgi php7-pdo php7-soap php7-posix php7-gettext php7-ldap php7-ctype php7-mbstring

## Installing phpMyAdmin
# Create a directory named webapps
RUN mkdir -p /usr/share/webapps
# Download the source code
WORKDIR /usr/share/webapps
RUN wget http://files.directadmin.com/services/all/phpMyAdmin/phpMyAdmin-5.0.4-all-languages.tar.gz
# Unpack the archive and remove the archive
RUN tar zxvf phpMyAdmin-5.0.4-all-languages.tar.gz
RUN rm phpMyAdmin-5.0.4-all-languages.tar.gz
# Rename the folder
RUN mv phpMyAdmin-5.0.4-all-languages phpmyadmin
# Change the folder permissions
RUN chmod -R 777 /usr/share/webapps/
# Create a symlink to the phpmyadmin folder
RUN ln -s /usr/share/webapps/phpmyadmin/ /var/www/localhost/htdocs/phpmyadmin

## https://docs.phpmyadmin.net/en/latest/setup.html#setup
WORKDIR /
ADD srcs/config.inc.php /usr/share/webapps/phpmyadmin/config.inc.php
ADD srcs/nginx.conf /etc/nginx/nginx.conf
ADD srcs/env.sh /env.sh
RUN chmod +x env.sh
RUN source env.sh

EXPOSE 5000

# CMD php -S 0.0.0.0:5000 -t /etc/phpmyadmin/
# CMD ["/bin/sh", "-c", "while true; do echo hello; sleep 10;done"]
CMD php-fpm7 && nginx -g "daemon off;"
