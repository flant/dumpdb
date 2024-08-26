FROM alpine:3.6@sha256:66790a2b79e1ea3e1dabac43990c54aca5d1ddf268d9a5a0285e4167c8b24475
RUN apk add --no-cache coreutils util-linux bash postgresql mysql-client
COPY dump.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/dump.sh
ENTRYPOINT ["/usr/local/bin/dump.sh"]
