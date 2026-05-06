{ pkgs, lib, ... }:
{
  # Enable Hyprland at the NixOS level so a .desktop session file is generated
  # for tuigreet to discover. Without this, greetd can't find the Hyprland session.
  # withUWSM registers a proper XDG session and handles systemd integration.
  # IMPORTANT: When using UWSM, home-manager's hyprland systemd.enable must be false
  # (set in hyprland.nix) to avoid conflicts.
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  # greetd — minimal, distro-agnostic display manager
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        # tuigreet: TUI greeter — keyboard-driven, fits the aesthetic
        # --sessions points to wayland-sessions dir so tuigreet discovers
        # the UWSM-registered Hyprland session (hyprland.desktop)
        # --remember / --remember-session persist last login across reboots
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --sessions /run/current-system/sw/share/wayland-sessions";
        user = "greeter";
      };
    };
  };

  # Prevent greetd restart loop on crash (default systemd config restarts
  # always, which causes a VT switching loop when the greeter exits)
  systemd.services.greetd = {
    serviceConfig = {
      Restart = lib.mkForce "on-failure";
      RestartSec = "5";
    };
  };

  # PAM: allow greetd to unlock gnome-keyring on login
  security.pam.services.greetd.enableGnomeKeyring = true;
}
