{ inputs, pkgs, lib, ... }:
{
  imports = [
    ./boot.nix
    ./networking.nix
    ./nix.nix
    ./security.nix
    ./services.nix
    ./virtualisation.nix
  ];

  # Core packages available system-wide
  environment.systemPackages = with pkgs; [
    vim
    git
    htop
    glances
    inxi
    lz4
    pv
  ];

  # Enable unfree packages
  nixpkgs.config.allowUnfree = true;

  # Hardware support
  hardware.bluetooth.enable = true;
  hardware.graphics.enable = true;
}
