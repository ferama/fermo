#! /bin/sh

if [ -f /etc/rospo/rospo.yaml ]; then
    service docker start
    runuser -l fermo -c "rospo /etc/rospo/rospo.yaml"
else
    echo ""
    echo "ERROR: file /etc/rospo/rospo.yaml not found"
    echo "you should mount the rospo.yaml file into the container"
    echo ""
    exec "$@"
fi