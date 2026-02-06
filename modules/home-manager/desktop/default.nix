{ pkgs, lib, ... }:
{
  imports = [
    ./hyprland.nix
    ./stylix.nix
  ];

  # GTK theming
  gtk = {
    enable = true;
    cursorTheme = {
      package = pkgs.vanilla-dmz;
      name = "Vanilla-DMZ";
      size = 24;
    };
  };

  # Qt theming
  qt = {
    enable = true;
    platformTheme.name = lib.mkForce "adwaita";
    style.name = lib.mkForce "adwaita-dark";
  };

  # Wayland environment variable for Electron apps
  home.sessionVariables.NIXOS_OZONE_WL = "1";

  # Desktop applications
  programs.kitty.enable = true;
  programs.firefox.enable = true;
  programs.mpv.enable = true;
  programs.yt-dlp.enable = true;
  programs.obs-studio.enable = true;
  programs.hyprlock.enable = true;
  programs.cava.enable = true;
  
  programs.rofi = {
    enable = true;
    plugins = [ pkgs.rofi-calc ];
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhs;
    userSettings = {
      "files.autoSave" = "afterDelay";
      "editor.wordWrap" = "on";
      "nix.enableLanguageServer" = true;
      "editor.minimap.enabled" = false;
      "workbench.panel.defaultLocation" = "right";
      "workbench.editor.showTabs" = "none";
      "update.showReleaseNotes" = false;
    };
  };

  # Blue light filter
  services.wlsunset = {
    enable = true;
    sunset = "20:00";
    sunrise = "8:00";
  };
}
