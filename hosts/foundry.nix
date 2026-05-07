{ inputs, ... }:
{
  imports = [
    ./default.nix
    ../modules/nixos/core.nix
    ../modules/nixos/desktop
    ../modules/nixos/users.nix
    ../hardware-configs/hw-foundry.nix
    ../modules/cachix.nix
    inputs.hardware.nixosModules.common-pc-laptop
    inputs.hardware.nixosModules.common-cpu-intel
  ];

  networking.hostName = "foundry";

  cathode.cachix.enable = true;

  # Use local RTC for Windows dual-boot compatibility
  # Windows expects hardware clock in local time; NixOS defaults to UTC
  time.hardwareClockInLocalTime = true;

  # Swap configuration (16GB swapfile)
  swapDevices = [{ device = "/swapfile"; size = 16 * 1024; }];

  # Home Manager configuration
  home-manager.users.user = import ../modules/home-manager/desktop.nix;
}
