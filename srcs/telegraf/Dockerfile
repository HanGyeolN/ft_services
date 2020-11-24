FROM alpine
MAINTAINER hna <hna@student.42seoul.kr>

RUN apk update
RUN apk add telegraf --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing/

ADD srcs/telegraf.conf /etc/telegraf/telegraf.conf

CMD ["telegraf"]
# CMD ["sh", "-c", "tail -f /dev/null"]
