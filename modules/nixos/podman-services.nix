{ pkgs, ... }:
let
  podmanServicesScript = pkgs.writeShellScriptBin "podman-services.sh" (builtins.readFile ../../scripts/podman-services.sh);
in
{
  # Deploy the wrapper script to /data
  system.activationScripts.podman-services-script = ''
    mkdir -p /data
    cp ${podmanServicesScript}/bin/podman-services.sh /data/podman-services.sh
    chmod +x /data/podman-services.sh
  '';

  # Auto-start all /data services on boot
  systemd.services.podman-services = {
    description = "Start all /data podman-compose services";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [ podman podman-compose bash ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "user";
      ExecStart = "/data/podman-services.sh up";
      ExecStop = "/data/podman-services.sh down";
    };
  };
}