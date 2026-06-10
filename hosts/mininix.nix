{ inputs, ... }:
{
  imports = [
    ./default.nix
    ../modules/nixos/core.nix
    ../modules/nixos/desktop
    ../modules/nixos/users.nix
    ../hardware-configs/hw-mininix.nix
    inputs.hardware.nixosModules.common-pc-ssd
    inputs.hardware.nixosModules.common-cpu-intel
  ];

  networking.hostName = "mininix";

  # Intel thermal monitoring and passive cooling
  services.thermald.enable = true;

  # Swap configuration (16GB swapfile)
  swapDevices = [{ device = "/swapfile"; size = 16 * 1024; }];

  # Home Manager configuration
  home-manager.users.user = import ../modules/home-manager/desktop.nix;
}
