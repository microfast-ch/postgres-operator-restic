FROM alpine:latest

RUN apk add restic postgresql-client bash pigz curl jq openssh-client
COPY dump.sh ./
ADD ssh-config /root/.ssh/config

ENTRYPOINT ["/dump.sh"]
