{ pkgs, lib, ... }:
{
  # ============================================================================
  # Desktop Home Manager Configuration
  # ============================================================================
  # User environment for desktop systems with GUI applications
  
  imports = [
    ./base.nix
  ];

  # ============================================================================
  # Desktop Packages
  # ============================================================================

  home.packages = with pkgs; [
    # Creative & Design
    gimp3
    openscad
    
    # Media & Entertainment
    parsec-bin
    moonlight-qt
    
    # Productivity
    obsidian
    
    # 3D Printing
    orca-slicer
  ];

  # ============================================================================
  # GTK Theme Configuration
  # ============================================================================

  gtk = {
    enable = true;
    cursorTheme = {
      package = pkgs.vanilla-dmz;
      name = "Vanilla-DMZ";
      size = 24;
    };
  };

  # ============================================================================
  # Qt Theme Configuration
  # ============================================================================

  qt = {
    enable = true;
    platformTheme.name = lib.mkForce "adwaita";
    style.name = lib.mkForce "adwaita-dark";
  };

  # ============================================================================
  # Wayland Environment
  # ============================================================================

  # Enable Wayland for Electron apps (VSCode, etc.)
  home.sessionVariables.NIXOS_OZONE_WL = "1";

  # ============================================================================
  # Window Manager - Hyprland
  # ============================================================================

  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = "source = ${../../dotfiles/.config/hypr/hyprland.conf}";
  };

  # ============================================================================
  # Desktop Applications
  # ============================================================================

  programs.kitty.enable = true;
  programs.firefox.enable = true;
  programs.mpv.enable = true;
  programs.yt-dlp.enable = true;
  programs.hyprlock.enable = true; # Not yet implemented
  
  programs.rofi = {
    enable = true;
    plugins = [ pkgs.rofi-calc ];
  };

  # VSCode with FHS environment for extension compatibility
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

  # ============================================================================
  # Desktop Services
  # ============================================================================

  # Blue light filter
  services.wlsunset = {
    enable = true;
    sunset = "20:00";
    sunrise = "8:00";
  };

  # ============================================================================
  # Theming - Stylix
  # ============================================================================

  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    image = pkgs.fetchurl {
      url = "https://cdnb.artstation.com/p/assets/images/images/025/145/885/large/kanistra-studio-20-workplace.jpg?1584794327";
      name = "kanistra-studio-20-workplace.jpg";
      sha256 = "1af4rgl9q5k93xy1bsk148rb1xp0cz6ax2gadiimq840yqrp6y79";
    };
    polarity = "dark";
    targets.firefox.enable = false;
  };
}
