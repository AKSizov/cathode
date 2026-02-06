{ pkgs, ... }:
{
  # Container support
  virtualisation.containers.enable = true;
  
  # Podman configuration
  virtualisation.podman = {
    enable = true;
    dockerCompat = true; # Docker compatibility alias
    defaultNetwork.settings.dns_enabled = true; # Enable DNS for containers
  };

  # Add podman-compose to system packages
  environment.systemPackages = with pkgs; [
    podman-compose
  ];
}
