{ pkgs, ... }:
{
  # System-wide theming with Stylix
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    image = pkgs.fetchurl {
      url = "https://cdna.artstation.com/p/assets/images/images/025/088/372/large/kanistra-studio-17-service-station.jpg?1584566564";
      name = "service-station.jpg";
      sha256 = "1af4rgl9q5k93xy1bsk148rb1xp0cz6ax2gadiimq840yqrp6y79";
    };
    polarity = "dark";
    targets.console.enable = false;
  };
}
