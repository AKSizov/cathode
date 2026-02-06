{ ... }:
{
  # Hyprland configuration
  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = "source = ${../../../dotfiles/.config/hypr/hyprland.conf}";
  };
}
