xhost local:root
XAUTH=/tmp/.docker.xauth

docker run -it \
    --name ros_humble \
    -v /home/whcheng/src:/root/src \
    --env="DISPLAY=$DISPLAY" \
    --env="QT_X11_NO_MITSHM=1" \
    -v "/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    --env="XAUTHORITY=$XAUTH" \
    --volume="$XAUTH:$XAUTH" \
    --privileged \
    ros_humble_v1 \
    bash

echo "Done."
