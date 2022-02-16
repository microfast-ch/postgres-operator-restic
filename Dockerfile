FROM debian:bullseye
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV PG_DIR=/usr/lib/postgresql

RUN apt-get update     \
    && apt-get install --no-install-recommends -y \
        apt-utils \
        ca-certificates \
        lsb-release \
        pigz \
        gnupg \
        curl \
        jq \
    && echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
    && cat /etc/apt/sources.list.d/pgdg.list \
    && curl --silent https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
    && apt-get update \
    && apt-get install --no-install-recommends -y  \
        postgresql-client-14  \
        postgresql-client-13  \
        postgresql-client-12  \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
    
RUN apk add restic postgresql-client bash pigz curl jq openssh-client
COPY dump.sh ./
ADD ssh-config /root/.ssh/config

ENTRYPOINT ["/dump.sh"]
