{
    pkgs,
    lib,
    ...
}:{

  imports = [
    # Base configuration
    ./base.nix
  ];

  home.packages = with pkgs; [ 
    #steam
    gimp3
    blender
    freecad
    openscad-unstable
    openscad-lsp
    cava
    parsec-bin
    moonlight-qt
    obsidian
    hyprpanel
    orca-slicer
  ];

  gtk = {
    enable = true;
    cursorTheme = {
      package = pkgs.vanilla-dmz;
      name = "Vanilla-DMZ";
      size = 24;
    };
    # theme = lib.mkForce {
    #   name = "Adwaita-dark";
    #   package = pkgs.gnome-themes-extra;
    # };
  };

  qt = {
    enable = true;
    platformTheme.name = lib.mkForce "adwaita";
    style.name = lib.mkForce "adwaita-dark";
  };
  
  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = "source = ${../dotfiles/.config/hypr/hyprland.conf}";
  };
  home.sessionVariables.NIXOS_OZONE_WL = "1";

  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhs;
    profiles.default.userSettings = {
      "files.autoSave" = "afterDelay";
      "editor.wordWrap" = "on";
      "nix.enableLanguageServer" = true;
      "editor.minimap.enabled" = false;
      "workbench.panel.defaultLocation" = "right";
      "workbench.editor.showTabs" = "none";
      "update.showReleaseNotes" = false;
    };
    # https://github.com/nix-community/nix-vscode-extensions
    #extensions = with pkgs.vscode-marketplace; [
    #  pinage404.nix-extension-pack
    #];
  };

  programs.kitty.enable = true;
  programs.firefox.enable = true;
  programs.mpv.enable = true;
  programs.yt-dlp.enable = true;
  programs.obs-studio.enable = true;
  programs.hyprlock.enable = true;
  programs.cava.enable = true;
  programs.rofi = {
    enable = true;
    plugins = [
        pkgs.rofi-calc
    ];
  };

  services.wlsunset = {
    enable = true;
    sunset = "20:00";
    sunrise = "8:00";
  };

  stylix.enable = true;
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
  stylix.image = pkgs.fetchurl {
    url = "https://cdnb.artstation.com/p/assets/images/images/025/145/885/large/kanistra-studio-20-workplace.jpg?1584794327";
    name = "kanistra-studio-20-workplace.jpg";
    sha256 = "1af4rgl9q5k93xy1bsk148rb1xp0cz6ax2gadiimq840yqrp6y79";
  };
  stylix.polarity = "dark";
  stylix.targets.firefox.enable = false;

}
