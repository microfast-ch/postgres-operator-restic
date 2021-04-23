FROM alpine:latest

RUN apk add restic postgresql-client bash pigz curl jq
COPY dump.sh ./

ENTRYPOINT ["/dump.sh"]
