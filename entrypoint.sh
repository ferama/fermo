#! /bin/sh

# rospo /etc/rospo/rospo.yaml > /dev/null 2>&1 &
dockerd-entrypoint.sh  > /dev/null 2>&1 &

exec "$@"