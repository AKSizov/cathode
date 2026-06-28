#!/usr/bin/env bash
# /data/podman-services.sh - Podman services manager
# Called by systemd podman-services.service and the podman-services CLI
#
# Usage:
#   podman-services.sh up      — start all /data services
#   podman-services.sh down    — stop all /data services
#   podman-services.sh status  — show running containers

ACTION=${1:-up}

case "$ACTION" in
  up)
    for dir in /data/*/; do
      if [ -f "$dir/docker-compose.yml" ] || [ -f "$dir/docker-compose.yaml" ]; then
        echo ">>> Starting $dir"
        cd "$dir" || continue
        /run/current-system/sw/bin/podman compose up -d 2>&1 || true
      fi
    done
    ;;
  down)
    for dir in /data/*/; do
      if [ -f "$dir/docker-compose.yml" ] || [ -f "$dir/docker-compose.yaml" ]; then
        echo ">>> Stopping $dir"
        cd "$dir" || continue
        /run/current-system/sw/bin/podman compose down 2>&1 || true
      fi
    done
    ;;
  status)
    /run/current-system/sw/bin/podman ps -a --format "table {{.Names}}	{{.Status}}	{{.Ports}}"
    ;;
  *)
    echo "Usage: podman-services.sh {up|down|status}"
    exit 1
    ;;
esac
