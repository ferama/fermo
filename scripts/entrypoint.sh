#! /bin/sh

if [ -f /etc/rospo/rospo.yaml ]; then
    /usr/local/bin/dockerd-entrypoint.sh &
    runuser -l fermo -c "rospo /etc/rospo/rospo.yaml"
else
    /usr/local/bin/dockerd-entrypoint.sh
fi