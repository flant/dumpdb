FROM alpine:3.20@sha256:0a4eaa0eecf5f8c050e5bba433f58c052be7587ee8af3e8b3910ef9ab5fbe9f5
RUN apk add --no-cache coreutils util-linux bash postgresql mysql-client
COPY dump.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/dump.sh
ENTRYPOINT ["/usr/local/bin/dump.sh"]
