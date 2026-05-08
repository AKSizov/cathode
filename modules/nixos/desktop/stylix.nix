{ pkgs, ... }:
{
  # System-wide theming with Stylix
  # Stylix provides base theming (fonts, cursor, GTK/QT) but terminal/app
  # colors are handled by Noctalia's template system for a cohesive look.
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";
    image = pkgs.runCommand "wallpaper.png" {} ''
      ${pkgs.imagemagick}/bin/convert -size 1920x1080 xc:"#1a1b26" $out
    '';
    polarity = "dark";

    # Disable Stylix for apps where Noctalia templates take over
    targets = {
      console.enable = false;
      kitty.enable = false;
    };
  };
}
