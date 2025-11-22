# Already tested in arm64 architecture
FROM ros:humble-ros-base

# Update and install development tools
RUN apt-get update && apt-get install -y \
    git \
    wget \
    vim \
    usbutils \
    net-tools \
    build-essential \
    python3-pip \
    python3-colcon-common-extensions \
    python3-rosdep \
    ros-humble-desktop \
    ros-dev-tools \
    && rm -rf /var/lib/apt/lists/*

# Initialize rosdep
RUN rosdep update
RUN . /opt/ros/humble/setup.sh
RUN echo "source /opt/ros/humble/setup.sh" >> ~/.bashrc

RUN sudo apt install ros-humble-pcl* -y
RUN pip3 install \
    pyyaml \
    rospkg \
    opencv-python-headless \
    opencv-contrib-python \
    flask \
    waitress \
    numpy \
    scipy \
    datetime \
    modern_robotics \
    matplotlib 

RUN apt-get update && apt-get install -y v4l-utils
RUN sudo apt-get install libgstrtspserver-1.0 libgstreamer1.0-dev -y
RUN sudo apt install ros-humble-spacenav -y

RUN sudo apt-get update

RUN sudo apt install ros-$ROS_DISTRO-pcl* -y

RUN sudo apt-get update && apt-get install -y libgl1-mesa-glx libgl1-mesa-dri x11-apps

RUN pip3 install xacro
RUN sudo apt install ros-humble-joint-state-publisher-gui -y

RUN sudo apt-get install -y \
    ros-$ROS_DISTRO-grid-map-cv \
    ros-$ROS_DISTRO-grid-map-msgs \
    ros-$ROS_DISTRO-grid-map-ros \
    ros-$ROS_DISTRO-grid-map-sdf \
    libmpfr-dev libpcap-dev \
    libglpk-dev

RUN sudo apt-get install -y ros-$ROS_DISTRO-octomap
RUN sudo apt install ros-humble-grid-map-rviz-plugin -y
RUN sudo apt install ros-humble-grid-map* -y
RUN sudo apt install ros-humble-xacro -y
RUN sudo apt install ros-humble-controller-interface -y
RUN sudo apt install ros-humble-controller-manager -y
RUN sudo apt install ros-humble-ros2-control* -y

RUN sudo apt update && sudo apt upgrade -y
RUN pip3 uninstall numpy -y && pip3 install numpy==1.26.4

RUN sudo apt install ros-humble-moveit*

# Go to /src
RUN mkdir /root/src
WORKDIR /root

# ros2 helpers
RUN echo "source /usr/share/colcon_cd/function/colcon_cd.sh" >> ~/.bashrc
RUN echo "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" >> ~/.bashrc

RUN echo "ALL Done"
