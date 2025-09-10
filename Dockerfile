# ========================
# Dockerfile PX4 ROS 2 Deploy
# ========================
ARG ROS_DISTRO=humble
FROM ros:${ROS_DISTRO}-ros-core

# Re-declare ARG after FROM
ARG ROS_DISTRO=humble

# Set noninteractive mode for apt
ENV DEBIAN_FRONTEND=noninteractive

# Install useful tools and required ROS packages
RUN apt update && \
    apt install -y \
        bash-completion \
        locales \
        curl \
        wget \
        git \
        nano \
        lsb-release \
        python3-rosdep \
        python3-colcon-common-extensions \
  build-essential \
  cmake \
  pkg-config \
  libasio-dev \
  libtinyxml2-dev \
        sudo && \
    locale-gen en_US en_US.UTF-8 && \
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 && \
    rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# Micro-XRCE-DDS-Agent
RUN git clone https://github.com/eProsima/Micro-XRCE-DDS-Agent.git  && \
    cd Micro-XRCE-DDS-Agent && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make && \
    sudo make install && \
    sudo ldconfig /usr/local/lib/ && \
    cd .. && \
    rm -rf Micro-XRCE-DDS-Agent

# ros repos
WORKDIR /root/ros2_ws/src
RUN git clone -b release/1.16 https://github.com/PX4/px4_msgs.git
WORKDIR /root/ros2_ws
RUN . /opt/ros/${ROS_DISTRO}/setup.sh && colcon build

# Source ROS and workspace in bashrc
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> /root/.bashrc && \
    echo "source /root/ros2_ws/install/setup.bash" >> /root/.bashrc && \
    sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' ~/.bashrc

# Default shell
SHELL ["/bin/bash", "-c"]

# Default command
CMD ["bash"]