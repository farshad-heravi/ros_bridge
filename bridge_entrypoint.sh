#!/bin/bash
set -e

# Source ROS environments
source /opt/ros/noetic/setup.bash
source /root/ros2_humble/install/setup.bash
source /bridge_ws/install/setup.bash

# Run the bridge
exec ros2 run ros1_bridge dynamic_bridge --bridge-all-topics
