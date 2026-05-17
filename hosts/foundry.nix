{ inputs, lib, ... }:
{
  imports = [
    ./default.nix
    ../modules/nixos/core.nix
    ../modules/nixos/desktop
    ../modules/nixos/gaming.nix
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


  # ThinkPad fan control — aggressive curve for gaming workloads
  # T14 Gen3 defaults are tuned for silence; this prioritizes thermals
  services.thinkfan = {
    enable = true;
    levels = [
      [0 0 55]
      [1 48 60]
      [2 55 65]
      [3 60 70]
      [4 65 75]
      [5 70 80]
      [6 75 85]
      [7 80 32767]    # full blast at 80°C+
    ];
  };

  # Home Manager configuration
  home-manager.users.user = import ../modules/home-manager/desktop.nix;
}
