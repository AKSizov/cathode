{ inputs, ... }:
{
  imports = [
    ../default.nix
    ../../modules/nixos/core.nix
    ../../modules/nixos/desktop
    ../../modules/nixos/users.nix
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

  # Home Manager configuration
  home-manager.users.user = import ../../modules/home-manager/desktop.nix;
}
