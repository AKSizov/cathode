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
    extraConfig = "source = ${../../dotfiles/.config/hypr/hyprland.conf}";
  };
}
