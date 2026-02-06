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

  # Home Manager configuration
  home-manager.users.user = import ../modules/home-manager/desktop.nix;
}
