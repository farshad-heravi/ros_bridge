# ROS1-ROS2 Bridge (Noetic & Humble)

**Author:** Farshad Heravi (f.n.heravi@gmail.com)  
**Repo:** [https://github.com/farshad-heravi/ros_bridge](https://github.com/farshad-heravi/ros_bridge)

This repository provides a Dockerized environment for bridging **ROS 1 Noetic** and **ROS 2 Humble**. Since these two ROS distributions are typically supported on different Ubuntu distributions (Ubuntu 20.04 Focal for Noetic and Ubuntu 22.04 Jammy for Humble), this project uses a custom Dockerfile based on Ubuntu 20.04. It installs ROS 1 Noetic from standard repositories, builds ROS 2 Humble from source, and finally builds the `ros1_bridge` package to enable bidirectional communication between the two ROS distributions.

## Features
- **Containerized Environment:** Run the ROS 1 - ROS 2 bridge without polluting the host system.
- **Dynamic Bridging:** Automatically bridges all topics using `ros1_bridge dynamic_bridge`.
- **Pre-configured Docker Compose:** Easily spin up the bridge using `docker-compose.yaml`.
- **Testing Environment:** Includes a comprehensive test suite `docker-compose-testing.yml` to verify bidirectional communication between ROS 1 and ROS 2 talkers and listeners.

## Files Structure
- `Dockerfile`: The main instruction file to build the image (`fnh_ros_bridge:noetic-humble`). It installs all necessary dependencies, configures the ROS workspaces, and compiles `ros1_bridge`.
- `docker-compose.yaml`: Runs just the ROS bridge container in host network mode for standard usage.
- `docker-compose-testing.yml`: A test suite that spins up a ROS 1 Master (`roscore`), Talkers, and Listeners in both ROS 1 and ROS 2 along with the bridge.
- `bridge_entrypoint.sh`: The entrypoint script for the Docker container that automatically sources both ROS workspaces and starts the bridge.

## Getting Started

### Prerequisites
- Docker
- Docker Compose

### Building the Image

You can build the Docker image using Docker Compose:

```bash
docker compose build
```

Or using plain Docker:

```bash
docker build -t fnh_ros_bridge:noetic-humble .
```

### Running the Bridge

If you simply want to run the bridge on your host machine (assuming you have a ROS 1 Master running locally or on the host network):

```bash
docker compose up ros1-bridge
```

The container uses `network_mode: host`, so it can seamlessly discover topics published on your host machine's ROS networks. It expects a ROS 1 master running at `http://localhost:11311` by default.

### Testing the Bridge

The repository includes a ready-to-use testing environment. The test suite launches:
- `ros1-master`: ROS Core (ROS 1).
- `ros1-talker`: Publishes standard string messages to `/chatter_1` (ROS 1).
- `ros2-talker`: Publishes standard string messages to `/chatter_2` (ROS 2).
- `ros1-listener`: Echoes `/chatter_2` via the bridge (ROS 1).
- `ros2-listener`: Echoes `/chatter_1` via the bridge (ROS 2).

To run the test suite:

```bash
docker compose -f docker-compose-testing.yml up
```

You should see logs from `ros1-listener` receiving ROS 2 messages, and `ros2-listener` receiving ROS 1 messages, confirming that the bridge is functioning correctly in both directions.

## Customization

You can modify `docker-compose.yaml` to change the `ROS_MASTER_URI` or `ROS_DOMAIN_ID` variables as needed based on your current existing setup.

## License & Credits
Author: Farshad Heravi
