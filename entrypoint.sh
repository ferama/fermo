#! /bin/sh

docker-entrypoint.sh dockerd > /dev/null 2>&1 &

exec "$@"