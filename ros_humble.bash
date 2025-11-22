xhost local:root
XAUTH=/tmp/.docker.xauth

docker run -it \
    -v /home/whcheng/src/ros_humble_ws:/root/ros2_docker_ws \
    -v /home/whcheng/src/ocs2_ros2_ws:/root/ocs2_ros2_ws \
    --env="DISPLAY=$DISPLAY" \
    --env="QT_X11_NO_MITSHM=1" \
    -v "/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    --env="XAUTHORITY=$XAUTH" \
    --volume="$XAUTH:$XAUTH" \
    --privileged \
    ros_humble_v1 \
    bash

echo "Done."