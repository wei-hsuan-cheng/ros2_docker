# Dockerized ROS 2 Environment

## Build image and run container

With Docker Compose (recommended):

```bash
docker compose build                  # image ros_humble
docker compose up -d                  # container ros_humble
docker compose exec ros_humble bash   # a shell in it (repeat for more terminals)
```

Or with the plain script, which creates the same container without GPU passthrough:

```bash
docker build -t ros_humble .
chmod +x ros_humble.bash
./ros_humble.bash
```

Both mount `~/src` at `/root/src`. To mount another folder with Compose, e.g. the Mac's `~/src` on a Parallels VM: `SRC_DIR=/media/psf/Home/src docker compose up -d`.

Compose does not run `xhost` the way the script does, so allow root on the X server first (the `~/.bashrc` snippet below does this).

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
docker compose exec ros_humble nvidia-smi
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
docker compose start                  # or: docker start ros_humble
docker compose exec ros_humble bash   # or: docker exec -it ros_humble bash
```

Run `rviz2` to see if x11 display setting works well

```bash
rviz2
```