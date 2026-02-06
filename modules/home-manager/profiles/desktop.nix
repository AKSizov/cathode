{ pkgs, lib, ... }:
{
  imports = [
    ../core
    ../desktop
  ];

  home = {
    username = "user";
    homeDirectory = "/home/user";
    stateVersion = "24.11";
  };

  # Desktop-specific packages
  home.packages = with pkgs; [
    gimp3
    blender
    freecad
    openscad-unstable
    openscad-lsp
    cava
    parsec-bin
    moonlight-qt
    obsidian
    orca-slicer
  ];
}
