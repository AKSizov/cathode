{ inputs, ... }:
{
  imports = [
    ../default.nix
    ../../modules/nixos/core
    ../../modules/nixos/hardware/nvidia.nix
    ../../hardware-configs/hw-closetcard.nix
    inputs.hardware.nixosModules.common-pc-ssd
    inputs.hardware.nixosModules.common-gpu-nvidia
    inputs.hardware.nixosModules.common-cpu-intel
  ];

  networking.hostName = "closetcard";

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
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;

  # User configuration
  users.users.user = {
    initialPassword = "correcthorsebatterystaple";
    isNormalUser = true;
    linger = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILp3QWpsKLZtI38se2R5JatwUUJ4g6i95cTvYtYTo5Wb"
    ];
    extraGroups = [ "wheel" "video" "audio" "networkmanager" ];
  };

  home-manager.users.user = import ../../modules/home-manager/profiles/headless.nix;
}
