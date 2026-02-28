{ pkgs, ... }:
{
  imports = [
    ./audio.nix
    ./stylix.nix
  ];

  # Desktop environment packages
  environment.systemPackages = with pkgs; [
    hyprpolkitagent
    nautilus
    gparted
    firefox
    kitty
  ];

  # Required for Home Manager xdg.portal to work properly
  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
  ];

  # Key remapping: Tab becomes Super when held
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      extraConfig = ''
        [main]
        # overload(modifier_layer, tap_action)
        tab = overload(meta, tab)
      '';
    };
  };

  # Fonts
  fonts = {
    packages = with pkgs; [
      # Nerd Fonts
      nerd-fonts.fira-code
      nerd-fonts.symbols-only
      
      # Icons
      material-design-icons
      font-awesome
      
      # Language support (CJK, Arabic, etc.) + Emoji
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      
      # UI
      inter
      roboto
    ];

    fontconfig = {
      defaultFonts = {
        monospace = [ "FiraCode Nerd Font Mono" "Noto Sans Mono CJK SC" "Symbols Nerd Font" "Noto Color Emoji" ];
        sansSerif = [ "Inter" "Noto Sans CJK SC" "Noto Color Emoji" ];
        serif = [ "Noto Serif" "Noto Serif CJK SC" ];
        emoji = [ "Noto Color Emoji" ];
      };
      
      hinting.enable = true;
      hinting.style = "slight";  # or "medium" if you prefer sharper
    };
  };

  # Security and authentication
  security.rtkit.enable = true;
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.hyprland.enableGnomeKeyring = true;

  # Desktop services
  services.upower.enable = true;
  services.blueman.enable = true;
  services.libinput.enable = true;
  services.power-profiles-daemon.enable = true;
  services.ollama.enable = true;

  # Bluetooth
  hardware.bluetooth.powerOnBoot = false;

  # Auto-login
  services.getty.autologinUser = "user";
}
