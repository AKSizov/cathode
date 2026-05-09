{ inputs, lib, ... }:
{
  imports = [
    ./default.nix
    ../modules/nixos/core.nix
    ../modules/nixos/desktop
    ../modules/nixos/users.nix
    ../hardware-configs/hw-foundry.nix
    inputs.hardware.nixosModules.common-pc-laptop
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  networking.hostName = "foundry";

  # Use local RTC for Windows dual-boot compatibility
  # Windows expects hardware clock in local time; NixOS defaults to UTC
  time.hardwareClockInLocalTime = true;

  # Swap configuration (16GB swapfile)
  swapDevices = [{ device = "/swapfile"; size = 16 * 1024; }];

  # Secure boot
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };


  # Home Manager configuration
  home-manager.users.user = import ../modules/home-manager/desktop.nix;
}
