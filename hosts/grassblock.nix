{ inputs, ... }:
{
  imports = [
    ./default.nix
    ../modules/nixos/core.nix
    ../modules/nixos/users.nix
    ../hardware-configs/grassblock.nix
  ];

  networking.hostName = "grassblock.net";

  # Disable sleep/suspend (headless server)
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # Enable auto-upgrades with reboot
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;

  # Home Manager configuration (headless)
  home-manager.users.user = import ../modules/home-manager/base.nix;
}
