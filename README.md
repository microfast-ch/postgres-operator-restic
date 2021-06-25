# postgres-operator-restic
Restic logical backup job for zalando/postgres-operator.

It is based on [zalando/postgres-operator/docker/logical-backup](https://github.com/zalando/postgres-operator/tree/v1.6.0/docker/logical-backup) but runs backups using [restic](https://github.com/restic/restic/) instead of S3.

This image can be configured as `logical_backup_docker_image`.
The operator have to be configured with the following settings in order to supply credentials to restic:
```plaintext
  additional_secret_mount: "postgres-restic"
  additional_secret_mount_path: "/var/run/restic-data"
  logical_backup_docker_image: "[the image build from this repository]"
```

Whereas the `postgres-restic` secret can have these keys:
- `env`: File which is sources before running restic
- `id_rsa`: File which is used as rsa ssh private key for sftp connections
- `repository`: String that is exported as `RESTIC_REPOSITORY`
- `password`: String that is exported as `RESTIC_PASSWORD`
