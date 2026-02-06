{ ... }:
{
  # Hyprland window manager
  programs.hyprland.enable = true;

  # Key remapping: Tab becomes Super when held
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      extraConfig = ''
        [main]
        # overload(modifier_layer, tap_action)
        tab = overload(meta, tab)
      '';
    };
  };

  # Dynamic linker for running unpatched binaries
  programs.nix-ld.enable = true;
}
