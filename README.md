# Dockerized ROS 2 Environment

### Build image and run container

```bash
docker build -t ros_humble_v1 .
chmod +x ros_humble.bash
./ros_humble.bash
```

* Run rviz2 to see if xhost display setting works well
```bash
rviz2
```