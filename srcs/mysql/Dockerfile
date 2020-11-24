FROM alpine
MAINTAINER hna <hna@student.42seoul.kr>

RUN apk update
RUN apk add mysql mysql-client

ADD srcs/mariadb-server.cnf /etc/my.cnf.d/mariadb-server.cnf
ADD srcs/entrypoint.sh /entrypoint.sh
ADD srcs/init.sql /init.sql
# mysql 소켓 기본경로. 만들어주지 않으면 실행시 에러
RUN mkdir /run/mysqld

EXPOSE 3306

ENTRYPOINT ["/entrypoint.sh"]
