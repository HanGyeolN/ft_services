FROM alpine
MAINTAINER hna <hna@student.42seoul.kr>

RUN apk update
RUN apk add influxdb

ADD srcs/influxdb.conf /etc/influxdb/influxdb.conf
ADD srcs/entrypoint.sh /entrypoint.sh
ADD srcs/create_users.sh /create_users.sh
RUN chmod +x entrypoint.sh

EXPOSE 8086

ENTRYPOINT ["/entrypoint.sh"]
# CMD ["sh", "-c", "tail -f /dev/null"]
