# Author: Farshad Heravi (f.n.heravi@gmail.com)
# Project: ROS1-ROS2 Bridge (Noetic & Humble)
# Repo: https://github.com/farshad-heravi/ros_bridge
# Description: Dockerfile for building a container with both ROS Noetic and ROS Humble for bridge purposes.

FROM ubuntu:focal

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install basics
RUN apt-get update && apt-get install -y \
    curl \
    gnupg2 \
    lsb-release \
    software-properties-common \
    wget \
    locales \
    software-properties-common && \
	locale-gen en_US en_US.UTF-8 && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 && \
	rm -rf /var/lib/apt/lists/*
ENV LANG=en_US.UTF-8

# Install ROS2 Humble
RUN apt update && \
	export ROS_APT_SOURCE_VERSION=$(curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F "tag_name" | awk -F\" '{print $4}') && \
	curl -L -o /tmp/ros2-apt-source.deb "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo ${UBUNTU_CODENAME:-${VERSION_CODENAME}})_all.deb" && \
	dpkg -i /tmp/ros2-apt-source.deb && \
    rm /tmp/ros2-apt-source.deb && \
	apt update && apt-get install -y --no-install-recommends \
	python3-flake8-docstrings \
	python3-pip \
	python3-pytest-cov \
	ros-dev-tools \
	libopencv-imgproc-dev \
	libacl1-dev \
	libtinyxml2-dev \
	libssl-dev \
	libldap2-dev \
	libasio-dev \
	libeigen3-dev \
	python3-dev && \
	rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install -U \
	flake8-blind-except \
	flake8-builtins \
	flake8-class-newline \
	flake8-comprehensions \
	flake8-deprecated \
	flake8-import-order \
	flake8-quotes \
	"pytest>=5.3" \
	pytest-repeat \
	pytest-rerunfailures \
	lark \
	numpy \
	empy==3.3.4
RUN mkdir -p ~/ros2_humble/src && cd ~/ros2_humble && \
	vcs import --input https://raw.githubusercontent.com/ros2/ros2/humble/ros2.repos src
ENV ROS_DISTRO=humble
RUN rosdep init && rosdep update && \
	rosdep install --from-paths src --ignore-src -y --skip-keys "fastcdr rti-connext-dds-6.0.1 urdfdom_headers" || true && \
    rm -rf /var/lib/apt/lists/*
RUN cd ~/ros2_humble/ && \
	colcon build --packages-up-to rclcpp ros2cli tf2_ros && \
	colcon build --packages-select diagnostic_msgs && \
	colcon build --packages-select \
		ros2cli \
		ros2run \
		ros2pkg \
		ros2node \
		ros2topic \
		ros2service \
		ros2param \
		ros2launch \
		ros2interface \
		ros2action \
		ros2lifecycle \
		ros2component \
		ros2doctor \
		ros2multicast \
		std_srvs \
		rosidl_runtime_py \
		launch_ros \
		launch_testing_ros \
		ros2cli_test_interfaces \
		ros2lifecycle_test_fixtures && \ 
	rm -rf src build log


# Install ROS1 Noetic
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu focal main" > /etc/apt/sources.list.d/ros1-latest.list'
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -

RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-noetic-ros-comm \
    ros-noetic-std-msgs \
    ros-noetic-geometry-msgs \
    ros-noetic-sensor-msgs \
    python3-rosdep \
    python3-rosinstall \
    python3-rosinstall-generator \
    && rm -rf /var/lib/apt/lists/*


# Build bridge
WORKDIR /bridge_ws
RUN mkdir -p /bridge_ws/src && \
	git clone https://github.com/ros2/ros1_bridge.git /bridge_ws/src/ros1_bridge

# Install bridge dependencies
ENV ROS_DISTRO=''
RUN /bin/bash -c "source /opt/ros/noetic/setup.bash && \
                  source /root/ros2_humble/install/setup.bash && \
                  rosdep install --from-paths src --ignore-src -y || true && \
                  rm -rf /var/lib/apt/lists/*"

RUN /bin/bash -c "source /opt/ros/noetic/setup.bash && \
                  source /root/ros2_humble/install/setup.bash && \
                  colcon build --packages-select ros1_bridge --cmake-force-configure && \
                  rm -rf src build log"

COPY bridge_entrypoint.sh /bridge_entrypoint.sh
RUN chmod +x /bridge_entrypoint.sh

ENTRYPOINT ["/bridge_entrypoint.sh"]