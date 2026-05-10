{ pkgs, ... }:
{
  # ============================================================================
  # Podman Service Manager
  # ============================================================================
  # KISS approach: systemd discovers and starts all docker-compose services
  # under /data on boot. No per-service NixOS config, no NixOS leakage into
  # /data. The entire /data directory remains portable — copy it to any host
  # with podman/docker and run `podman-compose up -d` in each service dir.

  # Convenience script for manual use:
  #   podman-services up      — start all /data services
  #   podman-services down    — stop all /data services  
  #   podman-services status  — show running containers
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "podman-services" ''
      ACTION=''${1:-up}
      case "$ACTION" in
        up)
          for dir in /data/*/; do
            if [ -f "$dir/docker-compose.yml" ] || [ -f "$dir/docker-compose.yaml" ]; then
              echo ">>> Starting $dir"
              cd "$dir" || continue
              ${pkgs.podman-compose}/bin/podman-compose up -d 2>&1 || true
            fi
          done
          ;;
        down)
          for dir in /data/*/; do
            if [ -f "$dir/docker-compose.yml" ] || [ -f "$dir/docker-compose.yaml" ]; then
              echo ">>> Stopping $dir"
              cd "$dir" || continue
              ${pkgs.podman-compose}/bin/podman-compose down 2>&1 || true
            fi
          done
          ;;
        status)
          ${pkgs.podman}/bin/podman ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
          ;;
        *)
          echo "Usage: podman-services {up|down|status}"
          ;;
      esac
    '')
  ];

  # Create the shared "main" podman network on boot
  systemd.services.podman-network-main = {
    description = "Create main podman network";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    path = [ pkgs.podman ];
    script = "podman network create main 2>/dev/null || true";
    serviceConfig.RemainAfterExit = true;
  };

  # Auto-start all /data services on boot
  systemd.services.podman-services = {
    description = "Start all /data podman-compose services";
    after = [ "podman-network-main.service" ];
    wants = [ "podman-network-main.service" ];
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [ podman podman-compose bash ];
    serviceConfig.Type = "oneshot";
    script = ''
      for dir in /data/*/; do
        if [ -f "$dir/docker-compose.yml" ] || [ -f "$dir/docker-compose.yaml" ]; then
          echo ">>> Starting $dir"
          cd "$dir" || continue
          podman-compose up -d 2>&1 || true
        fi
      done
    '';
    serviceConfig.RemainAfterExit = true;
  };
}
