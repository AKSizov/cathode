{ inputs, lib, ... }:
{
  imports = [
    ./default.nix
    ../modules/nixos/core.nix
    ../modules/nixos/desktop
    ../modules/nixos/users.nix
    ../hardware-configs/hw-m1n1x.nix
    inputs.nixos-apple-silicon.nixosModules.apple-silicon-support
  ];

  networking.hostName = "m1n1x";
  system.stateVersion = lib.mkDefault "26.05";

  # Swap configuration (16GB swapfile)
  swapDevices = [{ device = "/swapfile"; size = 16 * 1024; }];

  # Apple Silicon specific configuration
  boot.kernelParams = [ "apple_dcp.show_notch=1" ];
  boot.extraModprobeConfig = ''
    options hid_apple fnmode=2 swap_fn_leftctrl=1
  '';
  boot.loader.efi.canTouchEfiVariables = false;

  # Home Manager configuration
  home-manager.users.user = import ../modules/home-manager/desktop.nix;
}
