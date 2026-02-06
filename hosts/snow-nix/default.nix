{ inputs, ... }:
{
  imports = [
    ../default.nix
    ../../modules/nixos/core
    ../../modules/nixos/desktop
    ../../modules/nixos/hardware/nvidia.nix
    ../../hardware-configs/hw-snow-nix.nix
    inputs.hardware.nixosModules.common-pc-ssd
    inputs.hardware.nixosModules.common-gpu-nvidia
    inputs.hardware.nixosModules.common-cpu-intel
  ];

  networking.hostName = "snow-nix";

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

  home-manager.users.user = import ../../modules/home-manager/profiles/desktop.nix;
}
