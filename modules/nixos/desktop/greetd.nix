{ inputs, pkgs, ... }:
{
  # Hyprland compositor at NixOS level (UWSM for session management)
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  # Noctalia Greeter — graphical login that matches the shell theme
  imports = [ inputs.noctalia-greeter.nixosModules.default ];

  programs.noctalia-greeter = {
    enable = true;
    settings = {
      cursor = {
        theme = "Bibata-Modern-Classic";
        size = 24;
        path = "${pkgs.bibata-cursors}/share/icons";
      };
      keyboard = {
        layout = "us";
        variant = "dvorak";
      };
    };
  };
}
