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
  fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];

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
