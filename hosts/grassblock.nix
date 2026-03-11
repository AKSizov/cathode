{ inputs, ... }:
{
  imports = [
    ./default.nix
    ../modules/nixos/core.nix
    ../modules/nixos/users.nix
    ../hardware-configs/hw-grassblock.nix
  ];

  networking.hostName = "grassblock";

  # Disable sleep/suspend (headless server)
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 80;
  networking.firewall.enable = false;

  boot.loader.systemd-boot.enable = false;
  boot.loader.efi = {
    efiSysMountPoint = "/boot/efi";
    canTouchEfiVariables = false;
  };
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    efiInstallAsRemovable = true;
  };

  # Enable auto-upgrades with reboot
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;

  # Home Manager configuration (headless)
  home-manager.users.user = import ../modules/home-manager/base.nix;
}
