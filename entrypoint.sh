#! /bin/sh

export PATH=$PATH:/usr/local/bin
dockerd-entrypoint.sh > /dev/null 2>&1 &

exec "$@"