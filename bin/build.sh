#!/usr/bin/env bash

set -e

source .env

DOCKER_TAG=${1:-latest}

function print_usage
{
    echo
    echo "Usage: build.sh <DOCKER_TAG>"
    echo
    echo "Example:"
    echo "  build.sh latest"
}

if [[ -z "${DOCKER_TAG}" ]]
then
    echo "No DOCKER_TAG specified."
    print_usage
    exit 1
fi

echo "=> Building start with args"
echo "AWS_CLI_VERSION=${AWS_CLI_VERSION}"

echo "Build a image - mysql-s3-backup-restore:${DOCKER_TAG}"
docker build --pull \
    --build-arg "AWS_CLI_VERSION=${AWS_CLI_VERSION}" \
    -t "mysql-s3-backup-restore:${DOCKER_TAG}" .
