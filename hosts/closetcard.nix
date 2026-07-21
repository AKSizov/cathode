{ inputs, lib, ... }:
{
  imports = [
    ./default.nix
    ../modules/nixos/core.nix
    ../modules/nixos/users.nix
    ../hardware-configs/hw-closetcard.nix
    ../modules/nixos/hardware/nvidia.nix
    inputs.hardware.nixosModules.common-pc-ssd
    inputs.hardware.nixosModules.common-gpu-nvidia
    inputs.hardware.nixosModules.common-cpu-intel
  ];

  networking.hostName = "closetcard";
  system.stateVersion = lib.mkDefault "25.11";

  # Static IP configuration
  networking.useDHCP = false;
  networking.interfaces.eno1.ipv4.addresses = [{
    address = "192.168.1.101";
    prefixLength = 24;
  }];
  networking.defaultGateway = "192.168.1.1";

  # Disable sleep/suspend (headless server)
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # Enable auto-upgrades with reboot
  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    flake = "github:AKSizov/cathode/stable";
    flags = [
      "--refresh"
      "-L"
    ];
  };

  # Home Manager configuration (headless)
  home-manager.users.user = import ../modules/home-manager/base.nix;
}
