#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "usage: $0 <docker image name or id>"
    exit 0
fi

CONTAINER_NAME=$1
# add container hostname to the local list of permitted names for X
xhost +local:`docker inspect --format='{{ .Config.Hostname }}' $CONTAINER_NAME`
docker run -it --rm --env="DISPLAY" --env="QT_X11_NO_MITSHM=1" --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" $CONTAINER_NAME
DOCKER_EXIT="$?"
# remove container hostname to the local list of permitted names for X
xhost -local:`docker inspect --format='{{ .Config.Hostname }}' $CONTAINER_NAME`

if [ "$DOCKER_EXIT" -eq 126 ]; then
    echo ""
    echo "Permission denied when starting docker"
    echo "Try running sudo $0 $1"
fi
