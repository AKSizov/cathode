{ pkgs, ... }:
{
  # System-wide theming with Stylix
  # DISABLED: Experimenting with Noctalia-only theming.
  # Set enable = true to restore Stylix theming.
  stylix = {
    enable = false;

    # Preserved for easy re-enable:
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";
    # image = pkgs.runCommand "wallpaper.png" {} ''
    #   ${pkgs.imagemagick}/bin/convert -size 1920x1080 xc:"#1a1b26" $out
    # '';
    # polarity = "dark";
    #
    # targets = {
    #   console.enable = false;
    #   kitty.enable = false;
    # };
  };
}
