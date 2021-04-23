# postgres-operator-restic
Restic logical backup job for zalando/postgres-operator.

It is based on [zalando/postgres-operator/docker/logical-backup](https://github.com/zalando/postgres-operator/tree/v1.6.0/docker/logical-backup) but runs backups using [restic](https://github.com/restic/restic/) instead of S3.
