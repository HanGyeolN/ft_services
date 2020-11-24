FROM alpine
MAINTAINER hna <hna@student.42seoul.kr>

RUN apk update
RUN apk add grafana --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing/

ADD srcs/database.yaml /usr/share/grafana/conf/provisioning/datasources/database.yaml
ADD srcs/* /usr/share/grafana/conf/provisioning/dashboards/

EXPOSE 3000

ENTRYPOINT ["grafana-server", "-homepath=/usr/share/grafana"]
# ENTRYPOINT ["/entrypoint.sh"]
# CMD ["sh", "-c", "tail -f /dev/null"]
