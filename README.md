# Dockerized ROS 2 Environment

## Build image and run container

ROS 2 Jazzy on Ubuntu 24.04 (the `humble` branch has the Humble version).

With Docker Compose. `-f` names the compose file, so these run from any directory; adjust the path to where this repo is cloned (on the Parallels VM: `/media/psf/Home/src/ros2_docker`).

```bash
docker compose -f ~/src/ros2_docker/docker-compose.yml build   # image ros_jazzy
docker compose -f ~/src/ros2_docker/docker-compose.yml up -d   # container ros_jazzy
docker exec -it ros_jazzy bash   # a shell in it (repeat for more terminals)
```

Compose mounts the Mac's `~/src` (shared by Parallels as `/media/psf/Home/src`) at `/root/src`. On another host, point Compose at your source folder instead: `SRC_DIR=$HOME/src docker compose -f ~/src/ros2_docker/docker-compose.yml up -d`.

Allow root on the X server before starting the container (the `~/.bashrc` snippet below does this).

### GPU, per machine

The container is `privileged`, so it sees the host's `/dev/dri` (when there is one) and Mesa renders on the GPU. `ipc: host` lets Mesa hand frames to the X server through shared memory.

| machine | build | start |
|---|---|---|
| Parallels VM on an Apple Silicon Mac (virgl GPU) | `docker compose -f ~/src/ros2_docker/docker-compose.yml build` | `docker compose -f ~/src/ros2_docker/docker-compose.yml up -d` |
| Linux PC, Intel/AMD GPU | `PIN_MESA_FOR_VIRGL=false docker compose -f ~/src/ros2_docker/docker-compose.yml build` | `SRC_DIR=$HOME/src docker compose -f ~/src/ros2_docker/docker-compose.yml up -d` |
| Linux PC, NVIDIA GPU | `PIN_MESA_FOR_VIRGL=false docker compose -f ~/src/ros2_docker/docker-compose.yml build` | `SRC_DIR=$HOME/src docker compose -f ~/src/ros2_docker/docker-compose.yml -f ~/src/ros2_docker/docker-compose.nvidia.yml up -d` |

- **Parallels:** the image pins Mesa to 24.0.5 (`PIN_MESA_FOR_VIRGL`, on by default), because Mesa 25.x draws rviz2's 3D view black on virgl. Without the pin or without `ipc: host`, the rviz2 and MuJoCo windows open but stay black.
- **Intel/AMD PC:** keep Ubuntu's latest Mesa. GPUs newer than mid-2024 (Intel Lunar Lake/Battlemage, AMD RX 9000) need it; older ones work either way.
- **NVIDIA PC:** needs the NVIDIA driver and the [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html) on the host. Check with `docker exec -it ros_jazzy nvidia-smi`.

Check which renderer the container uses:

```bash
apt install -y mesa-utils && glxinfo -B | grep "OpenGL renderer"
# virgl (Apple M2 Pro ...) / Intel / AMD / NVIDIA  -> GPU
# llvmpipe                                        -> software rendering on the CPU
```

## X11 display setting 
Copy and paste this snippet in `~/.bashrc`

```bash
# Docker/X11 auth for rviz2
HOST_XAUTHORITY=${XAUTHORITY:-$HOME/.Xauthority}
XAUTH_DIR=/tmp/.docker.xauth
XAUTH_FILE="$XAUTH_DIR/.Xauthority"
export XAUTH="$XAUTH_FILE"
export XAUTHORITY="$XAUTH_FILE"
refresh_docker_xauth() {
  [ -z "$DISPLAY" ] && return
  command -v xauth >/dev/null || return

  mkdir -p "$XAUTH_DIR" || { echo "Cannot create $XAUTH_DIR (need sudo?)"; return; }
  if [ ! -w "$XAUTH_DIR" ]; then
    echo "$XAUTH_DIR not writable; run: sudo chown $USER:$USER $XAUTH_DIR"
    return
  fi

  [ -f "$XAUTH_FILE" ] || touch "$XAUTH_FILE" || { echo "Cannot write $XAUTH_FILE"; return; }
  XAUTHORITY="$HOST_XAUTHORITY" xauth nlist "$DISPLAY" | sed 's/^..../ffff/' | xauth -f "$XAUTH_FILE" nmerge - >/dev/null
  chmod 644 "$XAUTH_FILE" 2>/dev/null || true
}
# run once per interactive shell; comment this out if you prefer manual
case "$-" in *i*) refresh_docker_xauth ;; esac

# allow root (container) to access X server
if [ -n "$DISPLAY" ] && command -v xhost >/dev/null; then
  xhost +SI:localuser:root >/dev/null 2>&1 || true
fi
```


Start container / open a new terminal of the container

```bash
docker start ros_jazzy
docker exec -it ros_jazzy bash
```

Run `rviz2` to see if x11 display setting works well

```bash
rviz2
```