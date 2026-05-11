{ pkgs, ... }:
let
  podmanServicesScript = pkgs.writeShellScriptBin "podman-services.sh" (builtins.readFile ../../scripts/podman-services.sh);
in
{
  # ============================================================================
  # Podman Service Manager
  # ============================================================================
  # KISS approach: systemd discovers and starts all docker-compose services
  # under /data on boot. No per-service NixOS config, no NixOS leakage into
  # /data. The entire /data directory remains portable — copy it to any host
  # with podman/docker and run `podman-compose up -d` in each service dir.

  # Deploy the wrapper script to /data (only if it doesn’t exist)
  system.activationScripts.podman-services-script = ''
    if [ ! -f /data/podman-services.sh ]; then
      mkdir -p /data
      cp ${podmanServicesScript}/bin/podman-services.sh /data/podman-services.sh
      chmod +x /data/podman-services.sh
      echo "Deployed /data/podman-services.sh"
    fi
  '';

  # Convenience CLI — delegates to the script in /data
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "podman-services" ''
      exec /data/podman-services.sh "$@"
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

  # Auto-start all /data services on boot — delegates to /data/podman-services.sh
  systemd.services.podman-services = {
    description = "Start all /data podman-compose services";
    after = [ "podman-network-main.service" ];
    wants = [ "podman-network-main.service" ];
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [ podman podman-compose bash ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "/data/podman-services.sh up";
      ExecStop = "/data/podman-services.sh down";
    };
  };
}
