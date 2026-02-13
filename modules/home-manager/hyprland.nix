{ pkgs, ... }:
{
  # ============================================================================
  # Hyprland Window Manager Configuration
  # ============================================================================

  home.packages = with pkgs; [
    brightnessctl
    playerctl
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = ''
      ${builtins.readFile ../../dotfiles/.config/hypr/hyprland-base.conf}
      ${builtins.readFile ../../dotfiles/.config/hypr/hyprland-custom.conf}
    '';
  };
}
