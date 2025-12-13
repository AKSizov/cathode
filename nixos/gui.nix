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

  hardware.pulseaudio.enable = false;
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

  security.rtkit.enable = true;
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.hyprland.enableGnomeKeyring = true;

  stylix.enable = true;
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
  stylix.image = pkgs.fetchurl {
    url = "https://cdna.artstation.com/p/assets/images/images/025/088/372/large/kanistra-studio-17-service-station.jpg?1584566564";
    sha256 = "sha256-0075yagfvmimns0yzvyrcnczmy47j33x3na9cin3ky359wxkxy5a=";
  };
  #stylix.image = "${../res/custom/wall.jpg}"; # Custom wallpaper

  stylix.polarity = "dark";
  stylix.targets.console.enable = false;

  services.ollama.enable = true;
  programs.hyprland.enable = true;
  programs.nix-ld.enable = true;
  services.preload.enable = true;

  # For hyprpanel
  services.upower.enable = true;
  services.blueman.enable = true;
  services.libinput.enable = true;
  services.power-profiles-daemon.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;

  services.getty.autologinUser = "user";
  
}