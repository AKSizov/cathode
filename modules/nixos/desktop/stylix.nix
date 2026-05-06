{ pkgs, ... }:
{
  # System-wide theming with Stylix
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";
    image = pkgs.runCommand "wallpaper.png" {} ''
      ${pkgs.imagemagick}/bin/convert -size 1920x1080 xc:"#1a1b26" $out
    '';
    polarity = "dark";
    targets.console.enable = false;
    # Tone down the Hyprland active border (base0D is used for borders)
    override = {
      base0D = "#7aa2f7";
    };
  };
}
