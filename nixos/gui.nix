{
    pkgs,
    ...
}:{

  environment.systemPackages = with pkgs; [
    hyprpolkitagent
    nautilus
    gparted
    firefox
    kitty
  ];

  fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    # jack.enable = true;
    # extraConfig.pipewire."92-low-latency" = {
    #   "context.properties" = {
    #     "default.clock.rate" = 48000;
    #     "default.clock.quantum" = 32;
    #     "default.clock.min-quantum" = 32;
    #     "default.clock.max-quantum" = 32;
    #   };
    # };

    # So, for some reason this example from the wiki doesn't actually use RT priority.
    # You have to run this command to change it manually on boot, for now. Not sure
    # where the bug is, but this command sets pipewire to realtime:
    # > sudo ps -C pipewire,pipewire-pulse,pipewire-media-session -o pid= | xargs -r -I{} sudo chrt -f -p 20 {}
    # -----
    # This can be confirmed by seeing FF instead of TS when running this command:
    # > ps -L -o pid,tid,cls,rtprio,cmd -C pipewire
  };

  # This section remaps tab to LWin for the sake of tiling window managers like hyprland.
  # A single press of the tab key still works as normal.  
  services.keyd = {
  enable = true;
  keyboards = {
    # The name is just the name of the configuration file, it does not really matter
    default = {
      ids = [ "*" ]; # what goes into the [id] section, here we select all keyboards
      # Everything but the ID section:
      extraConfig = ''
        [main]
        # overload(modifier_layer, tap_action)
        tab = overload(meta, tab)
      '';
    };
  };
};


  security.rtkit.enable = true;
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.hyprland.enableGnomeKeyring = true;

  stylix.enable = true;
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
  stylix.image = pkgs.fetchurl {
    url = "https://cdna.artstation.com/p/assets/images/images/025/088/372/large/kanistra-studio-17-service-station.jpg?1584566564";
    name = "service-station.jpg";
    sha256 = "1af4rgl9q5k93xy1bsk148rb1xp0cz6ax2gadiimq840yqrp6y79";
  };
  #stylix.image = "${../res/custom/wall.jpg}"; # Old version that worked

  stylix.polarity = "dark";
  stylix.targets.console.enable = false;

  services.ollama.enable = true;
  programs.hyprland.enable = true;
  programs.nix-ld.enable = true;

  # For hyprpanel
  services.upower.enable = true;
  services.blueman.enable = true;
  services.libinput.enable = true;
  services.power-profiles-daemon.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;

  services.getty.autologinUser = "user";
  
}