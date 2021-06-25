#!/bin/bash

# Based on https://github.com/zalando/postgres-operator/blob/v1.6.0/docker/logical-backup/dump.sh

set -o errexit
set -o nounset
set -o pipefail

TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
K8S_API_URL=https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT/api/v1
CERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt

function get_pods {
    declare -r SELECTOR="$1"

    curl "${K8S_API_URL}/namespaces/${POD_NAMESPACE}/pods?$SELECTOR" \
        --cacert $CERT \
        -H "Authorization: Bearer ${TOKEN}" | jq .items[].status.podIP -r
}

function get_current_pod {
    curl "${K8S_API_URL}/namespaces/${POD_NAMESPACE}/pods?fieldSelector=metadata.name%3D${HOSTNAME}" \
        --cacert $CERT \
        -H "Authorization: Bearer ${TOKEN}"
}

declare -a search_strategy=(
    list_all_replica_pods_current_node
    list_all_replica_pods_any_node
    get_master_pod
)

function list_all_replica_pods_current_node {
    get_pods "labelSelector=${CLUSTER_NAME_LABEL}%3D${SCOPE},spilo-role%3Dreplica&fieldSelector=spec.nodeName%3D${CURRENT_NODENAME}" | head -n 1
}

function list_all_replica_pods_any_node {
    get_pods "labelSelector=${CLUSTER_NAME_LABEL}%3D${SCOPE},spilo-role%3Dreplica" | head -n 1
}

function get_master_pod {
    get_pods "labelSelector=${CLUSTER_NAME_LABEL}%3D${SCOPE},spilo-role%3Dmaster" | head -n 1
}

CURRENT_NODENAME=$(get_current_pod | jq .items[].spec.nodeName --raw-output)
export CURRENT_NODENAME

for search in "${search_strategy[@]}"; do

    PGHOST=$(eval "$search")
    export PGHOST

    if [ -n "$PGHOST" ]; then
        break
    fi

done

# Configure supplied credentials from secrets
if [ -f /var/run/restic-data/id_rsa]; then
    cp /var/run/restic-data/id_rsa ~/.ssh/id_rsa
    chmod 600 ~/.ssh/id_rsa
fi

if [ -f /var/run/restic-data/env ]; then
    . /var/run/restic-data/env
fi

if [ -f /var/run/restic-data/repository ]; then
    export RESTIC_REPOSITORY=$(cat /var/run/restic-data/repository)
fi

if [ -f /var/run/restic-data/password ]; then
    export RESTIC_PASSWORD=$(cat /var/run/restic-data/password)
fi

# Backup data
pg_dumpall | pigz | restic -H $PGHOST backup --stdin --stdin-filename "$SCOPE$(date +%s).sql.gz"
