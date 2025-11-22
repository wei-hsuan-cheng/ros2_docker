# Dockerized ROS 2 Environment

## Build image and run container

```bash
docker build -t ros_humble_v1 .
chmod +x ros_humble.bash
./ros_humble.bash
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
docker start ros_humble
docker exec -it ros_humble bash
```

Run `rviz2` to see if x11 display setting works well

```bash
rviz2
```