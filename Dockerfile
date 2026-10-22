# Already tested in arm64 architecture
FROM ros:jazzy-ros-base

# Ubuntu 24.04 marks the system Python as externally managed (PEP 668), so a
# plain `pip3 install` is refused. This is a single-purpose container, so allow it.
ENV PIP_BREAK_SYSTEM_PACKAGES=1

# Update and install development tools
RUN apt-get update && apt-get install -y \
    sudo \
    git \
    wget \
    vim \
    usbutils \
    net-tools \
    build-essential \
    python3-pip \
    python3-colcon-common-extensions \
    python3-rosdep \
    ros-jazzy-desktop \
    ros-dev-tools \
    && rm -rf /var/lib/apt/lists/*

# Initialize rosdep
RUN rosdep update
RUN . /opt/ros/jazzy/setup.sh
RUN echo "source /opt/ros/jazzy/setup.sh" >> ~/.bashrc

RUN sudo apt update && sudo apt install ros-jazzy-pcl* -y
# numpy is pinned in the same call as opencv: Ubuntu 24.04 already ships
# python3-numpy 1.26.4, and pinning it here stops pip from pulling numpy 2 in on
# top of it, which the ROS Python packages are not built against.
# flask upgrades blinker, which Ubuntu 24.04 ships as a debian package pip cannot uninstall
RUN pip3 install --ignore-installed blinker
RUN pip3 install \
    pyyaml \
    rospkg \
    opencv-python-headless \
    opencv-contrib-python \
    flask \
    waitress \
    "numpy==1.26.4" \
    scipy \
    datetime \
    modern_robotics \
    matplotlib

RUN apt-get update && apt-get install -y v4l-utils
RUN sudo apt-get install libgstrtspserver-1.0-dev libgstreamer1.0-dev -y
RUN sudo apt install ros-jazzy-spacenav -y

RUN sudo apt-get update

RUN sudo apt install ros-$ROS_DISTRO-pcl* -y

# libgl1-mesa-glx no longer exists on Ubuntu 24.04; libgl1 + libglx-mesa0 replace it
RUN sudo apt-get update && apt-get install -y libgl1 libglx-mesa0 libgl1-mesa-dri x11-apps

RUN pip3 install xacro
RUN sudo apt install ros-jazzy-joint-state-publisher-gui -y

RUN sudo apt-get install -y \
    ros-$ROS_DISTRO-grid-map-cv \
    ros-$ROS_DISTRO-grid-map-msgs \
    ros-$ROS_DISTRO-grid-map-ros \
    ros-$ROS_DISTRO-grid-map-sdf \
    libmpfr-dev libpcap-dev \
    libglpk-dev

RUN sudo apt-get install -y ros-$ROS_DISTRO-octomap
RUN sudo apt install ros-jazzy-grid-map-rviz-plugin -y
RUN sudo apt install ros-jazzy-grid-map* -y
RUN sudo apt install ros-jazzy-xacro -y
RUN sudo apt install ros-jazzy-controller-interface -y
RUN sudo apt install ros-jazzy-controller-manager -y
RUN sudo apt install ros-jazzy-ros2-control* -y

RUN sudo apt update && sudo apt upgrade -y

RUN sudo apt install ros-jazzy-moveit* -y
RUN sudo apt install ros-jazzy-image-transport ros-jazzy-image-transport-plugins -y

# Go to /src
RUN mkdir /root/src
WORKDIR /root

# ros2 helpers
RUN echo "source /usr/share/colcon_cd/function/colcon_cd.sh" >> ~/.bashrc
RUN echo "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" >> ~/.bashrc

# Mesa 25.x (noble-updates) renders rviz2's 3D view black on a virgl GPU (Parallels on
# an Apple Silicon Mac), while Mesa 24.0.5 (noble release) works. Pin and hold it so apt
# upgrade does not bring 25.x back. Turn it off on a PC with a GPU newer than mid-2024
# (Intel Lunar Lake/Battlemage, AMD RX 9000), which needs the newer Mesa.
ARG PIN_MESA_FOR_VIRGL=true
RUN if [ "${PIN_MESA_FOR_VIRGL}" = "true" ]; then \
    MESA=24.0.5-1ubuntu1 && apt-get update && apt-get install -y --allow-downgrades \
      libgl1-mesa-dri=${MESA} libglx-mesa0=${MESA} libegl-mesa0=${MESA} \
      libgbm1=${MESA} libglapi-mesa=${MESA} libgbm-dev=${MESA} \
      libegl1-mesa-dev=${MESA} libgl1-mesa-dev=${MESA} \
      mesa-va-drivers=${MESA} mesa-vdpau-drivers=${MESA} mesa-vulkan-drivers=${MESA} && \
    apt-mark hold libgl1-mesa-dri libglx-mesa0 libegl-mesa0 libgbm1 libglapi-mesa \
      libgbm-dev libegl1-mesa-dev libgl1-mesa-dev mesa-va-drivers mesa-vdpau-drivers mesa-vulkan-drivers; \
  fi

RUN echo "ALL Done"
