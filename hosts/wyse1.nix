{ inputs, lib, ... }:
{
  imports = [
    ./default.nix
    ../modules/nixos/core.nix
    ../modules/nixos/users.nix
    ../modules/nixos/podman-services.nix
    ../hardware-configs/hw-wyse1.nix
  ];

  networking.hostName = "wyse1";

  # Disable sleep/suspend (headless server)
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 80;
  networking.firewall.enable = false;

  boot.loader.efi.efiSysMountPoint = lib.mkForce "/boot";

  # Enable auto-upgrades with reboot
  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    flake = "github:AKSizov/cathode/stable";  # Branch/ref goes in the URL, not a separate option
    flags = [
      "--refresh"  # Force re-fetch flake inputs (bypass cache)
      "-L"         # Print build logs
    ];
  };

  # Home Manager configuration (headless)
  home-manager.users.user = import ../modules/home-manager/base.nix;
}
