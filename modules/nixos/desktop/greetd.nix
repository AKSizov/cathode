{ pkgs, ... }:
{
  # Enable Hyprland at the NixOS level so a .desktop session file is generated
  # for tuigreet to discover. Without this, greetd can't find the Hyprland session.
  programs.hyprland = {
    enable = true;
    withUWSM = true; # UWSM wraps Hyprland with proper XDG session registration
  };

  # greetd — minimal, distro-agnostic display manager
  services.greetd = {
    enable = true;
    settings = {
      default = {
        # tuigreet: TUI greeter — keyboard-driven, fits the aesthetic
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --remember-session --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  # Prevent greetd restart loop on crash (default systemd config restarts
  # always, which causes a VT switching loop when the greeter exits)
  systemd.services.greetd = {
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "5";
    };
  };

  # PAM: allow greetd to unlock gnome-keyring on login
  security.pam.services.greetd.enableGnomeKeyring = true;
}
