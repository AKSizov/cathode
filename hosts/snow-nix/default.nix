{ inputs, ... }:
{
  imports = [
    ../default.nix
    ../../modules/nixos/core.nix
    ../../modules/nixos/desktop
    ../../modules/nixos/users.nix
    ../../modules/nixos/hardware/nvidia.nix
    ../../hardware-configs/hw-snow-nix.nix
    inputs.hardware.nixosModules.common-pc-ssd
    inputs.hardware.nixosModules.common-gpu-nvidia
    inputs.hardware.nixosModules.common-cpu-intel
  ];

  networking.hostName = "snow-nix";

  # Home Manager configuration
  home-manager.users.user = import ../../modules/home-manager/desktop.nix;
}
