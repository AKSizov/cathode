{ pkgs, ... }:
{
  # Enable Hyprland at the NixOS level with UWSM for proper session registration.
  # This creates a hyprland.desktop entry in wayland-sessions so tuigreet can find it.
  # IMPORTANT: When using UWSM, home-manager's hyprland systemd.enable must be false
  # (set in hyprland.nix) to avoid conflicts — UWSM handles systemd integration itself.
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  # greetd — minimal display manager
  services.greetd = {
    enable = true;
    useTextGreeter = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session";
      };
    };
  };
}
