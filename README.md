# mysql-s3-backup-restore
[![Build Status](https://travis-ci.org/ridibooks-docker/mysql-s3-backup-restore.svg?branch=master)](https://travis-ci.org/ridibooks-docker/mysql-s3-backup-restore)
[![](https://images.microbadger.com/badges/version/ridibooks/mysql-s3-backup-restore.svg)](http://microbadger.com/images/ridibooks/mysql-s3-backup-restore "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/image/ridibooks/mysql-s3-backup-restore.svg)](http://microbadger.com/images/ridibooks/mysql-s3-backup-restore "Get your own version badge on microbadger.com")

This repo is a modification of another. The original source is here: https://github.com/schickling/dockerfiles/tree/master/mysql-backup-s3

## Basic usage
```bash
docker run --rm \
    -e AWS_ACCESS_KEY_ID=key \
    -e AWS_SECRET_ACCESS_KEY=secret \
    -e AWS_DEFAULT_REGION=ap-northeast-2 \
    -e MYSQL_HOST=localhost \
    -e MYSQL_USER=user \
    -e MYSQL_PASSWORD=password \
    -e MYSQL_DATABASE=my_database \
    -e S3_BUCKET=my-bucket \
    -e S3_PREFIX=backup \
    ridibooks/mysql-s3-backup-restore \
    backup # .. or restore
```

## Environment variables
- `MYSQL_HOST` The MySQL host *required*
- `MYSQL_PORT` The MySQL port (default: 3306)
- `MYSQL_USER` The MySQL user *required*
- `MYSQL_PASSWORD` The MySQL password *required*
- `MYSQL_DATABASE` The databases you want to backup *required*
- `MYSQLDUMP_OPTIONS` mysqldump options (default: --quote-names --quick --add-drop-table --add-locks --allow-keywords --disable-keys --extended-insert --single-transaction --create-options --comments --net_buffer_length=16384)
- `S3_BUCKET` Your AWS S3 bucket path *required*
- `S3_PREFIX` The path prefix in your bucket (default: 'backup')
- `S3_FILENAME` The filename (default: ${MYSQL_DATABASE})
- `S3_OBJECT_ACL` Sets the ACL for the S3 object. (default: *no value*)
  > If you use this parameter you must have the "s3:PutObjectAcl" permission included in your IAM policy.
  > See https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl