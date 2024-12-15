#!/bin/bash
# automation script for docker containers to ensure even container images created with reboot:always
# running after rebooting the server.
# check sudo
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script with sudo or as the root user."
  exit 1
fi
# start container and check container status.
start_container() {
  container_name=$1
  container_status=$(docker inspect -f '{{.State.Status}}' "$container_name" 2>/dev/null)

  if [ "$container_status" == "running" ]; then
    echo "Container $container_name is already running."
  else
    echo "Starting container: $container_name"
    docker start "$container_name"
    wait_for_container "$container_name"
  fi
}
# wait for current container up and running before continuing to next one.
wait_for_container() {
  container_name=$1
  echo "Waiting for container $container_name to be fully up and running..."
  while [ "$(docker inspect -f '{{.State.Status}}' "$container_name")" != "running" ]; do
    sleep 2
  done
  echo "Container $container_name is now running."
}

# container start order.
start_container "portainer"
start_container "trilium"
start_container "nginx-web"
start_container "brave_dhawan"

# check containers before exit
echo "Running Docker containers:"
docker ps
echo "$(date '+%Y-%m-%d %H:%M:%S') - start_all.sh script executed successfully" >> /home/tarik/start_all.log
