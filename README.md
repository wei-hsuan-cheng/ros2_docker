# Dockerized ROS 2 Environment

## Build image and run container

ROS 2 Jazzy on Ubuntu 24.04 (the `humble` branch has the Humble version).

With Docker Compose:

```bash
docker compose build                 # image ros_jazzy
docker compose up -d                 # container ros_jazzy
docker compose exec ros_jazzy bash   # a shell in it (repeat for more terminals)
```

Compose mounts the Mac's `~/src` (shared by Parallels as `/media/psf/Home/src`) at `/root/src`. On another host, point Compose at your source folder instead: `SRC_DIR=$HOME/src docker compose up -d`.

Allow root on the X server before starting the container (the `~/.bashrc` snippet below does this).

### GPU

`docker-compose.yml` passes the host's DRM devices (`/dev/dri`) through, so Mesa renders on the GPU: virgl on a Parallels VM, the native driver on an Intel/AMD host. Check it from inside the container:

```bash
apt install -y mesa-utils && glxinfo -B | grep "OpenGL renderer"
# virgl (Apple M2 Pro ...)  -> GPU
# llvmpipe                  -> software rendering on the CPU
```

On a host with an NVIDIA GPU and the [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html), add the override file:

```bash
docker compose -f docker-compose.yml -f docker-compose.nvidia.yml up -d
docker compose exec ros_jazzy nvidia-smi
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
docker compose start
docker compose exec ros_jazzy bash
```

Run `rviz2` to see if x11 display setting works well

```bash
rviz2
```