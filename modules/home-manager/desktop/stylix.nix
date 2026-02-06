{ pkgs, ... }:
{
  # User-level theming with Stylix
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
