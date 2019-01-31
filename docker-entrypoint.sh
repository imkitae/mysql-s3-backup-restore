#!/usr/bin/env sh
set -e

print_usage()
{
    echo
    echo "Usage: docker-entrypoint.sh <command>"
    echo
    echo "Commands:"
    echo "  backup      Create DB dump, and upload it to S3"
    echo "  restore     Download the dump, and restore DB from it"
}

dump_db()
{
    echo "Create a dump of MySQL '${MYSQL_DATABASE}' from ${MYSQL_HOST}..."
    if ! mysqldump ${MYSQL_CLIENT_OPTIONS} ${MYSQL_DUMP_OPTIONS} ${MYSQL_DATABASE} | gzip > ${DUMP_PATH}
    then
        echo "Error creating dump of '${MYSQL_DATABASE}'" >&2
        exit 1
    fi

    echo "Dump finished: ${MYSQL_DATABASE} -> ${DUMP_PATH}"
}

restore_db()
{
    if ! mysql ${MYSQL_CLIENT_OPTIONS} -e "use ${MYSQL_DATABASE};"
    then
        echo "${MYSQL_DATABASE} doesn't exists. Create new one..."
        mysql ${MYSQL_CLIENT_OPTIONS} -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};"
    fi

    echo "Restore MySQL database from ${DUMP_PATH}..."
    if ! gunzip < ${DUMP_PATH} | mysql ${MYSQL_CLIENT_OPTIONS} ${MYSQL_DATABASE}
    then
        echo "Error restoring database" >&2
        exit 1
    fi

    echo "Restore finished: ${DUMP_PATH} -> ${MYSQL_DATABASE}"
}

upload_to_s3()
{
    echo "Uploading ${DUMP_PATH} on S3..."
    if ! aws s3 mv ${DUMP_PATH} ${S3_PATH}
    then
        echo "Error uploading ${DUMP_PATH} on S3" >&2
        exit 1
    fi

    echo "Upload finished: ${DUMP_PATH} -> ${S3_PATH}"
}

download_from_s3()
{
    echo "Downloading ${DUMP_PATH} from S3..."
    if ! aws s3 cp ${S3_PATH} ${DUMP_PATH}
    then
        echo "Error downloading ${DUMP_PATH} from S3" >&2
        exit 1
    fi

    echo "Download finished: ${S3_PATH} -> ${DUMP_PATH}"
}

assert()
{
    local variable_name=${1}
    eval "local variable=\$${variable_name}"

    if [[ -z "${variable}" ]]
    then
        echo "Error: You did not set the ${variable_name} environment variable." >&2
        exit 1
    fi
}

assert S3_BUCKET
assert S3_PREFIX

assert MYSQL_HOST
assert MYSQL_USER
assert MYSQL_DATABASE
assert MYSQL_DUMP_OPTIONS

COMMAND=${1}

S3_FILENAME="${S3_FILENAME:-${MYSQL_DATABASE}.sql.gz}"
S3_PATH="s3://${S3_BUCKET}/${S3_PREFIX}/${S3_FILENAME}"
DUMP_PATH="/tmp/${S3_FILENAME}"

if [[ -z "${MYSQL_PASSWORD}" ]]
then
    MYSQL_CLIENT_OPTIONS="-h${MYSQL_HOST} -P${MYSQL_PORT} -u${MYSQL_USER}"
else
    MYSQL_CLIENT_OPTIONS="-h${MYSQL_HOST} -P${MYSQL_PORT} -u${MYSQL_USER} -p${MYSQL_PASSWORD}"
fi

if [[ ${#} -lt 1 ]]
then
    print_usage
    exit 1
fi

if [[ "${COMMAND}" == "backup" ]]
then
    dump_db
    upload_to_s3

elif [[ "${COMMAND}" == "restore" ]]
then
    download_from_s3
    restore_db

else
    echo "Error: No command exists." >&2
    print_usage
    exit 1
fi
