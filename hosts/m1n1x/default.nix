{ inputs, ... }:
{
  imports = [
    ../default.nix
    ../../modules/nixos/core
    ../../modules/nixos/desktop
    ../../hardware-configs/hw-m1n1x.nix
    inputs.nixos-apple-silicon.nixosModules.apple-silicon-support
  ];

  networking.hostName = "m1n1x";

  # Apple Silicon specific configuration
  hardware.asahi.useExperimentalGPUDriver = true;
  boot.kernelParams = [ "apple_dcp.show_notch=1" ];
  boot.extraModprobeConfig = ''
    options hid_apple fnmode=2 swap_fn_leftctrl=1
  '';
  boot.loader.efi.canTouchEfiVariables = false;

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
