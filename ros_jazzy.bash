xhost local:root
XAUTH=/tmp/.docker.xauth

# On a Parallels VM, also mount the Mac's ~/src (shared as /media/psf/Home/src),
# so code edited on the Mac is built in the container directly.
MAC_SRC_MOUNT=""
if [ -d /media/psf/Home/src ]; then
    MAC_SRC_MOUNT="-v /media/psf/Home/src:/root/src"
fi

docker run -it \
    --name ros_jazzy \
    ${MAC_SRC_MOUNT} \
    --env="DISPLAY=$DISPLAY" \
    --env="QT_X11_NO_MITSHM=1" \
    -v "/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    --env="XAUTHORITY=$XAUTH" \
    --volume="$XAUTH:$XAUTH" \
    --privileged \
    ros_jazzy \
    bash

echo "Done."
