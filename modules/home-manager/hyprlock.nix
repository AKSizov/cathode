{ ... }:
{
  # ============================================================================
  # Hyprlock — Lock Screen
  # ============================================================================
  # Stylix's hyprlock target is disabled — we manage the full config here
  # so we can control the input field styling precisely.

  programs.hyprlock = {
    enable = true;

    settings = {
      general = {
        grace = 3;
        hide_cursor = true;
        no_fade_in = false;
      };

      background = [
        {
          path = "screenshot";
          blur_passes = 3;
          blur_size = 8;
        }
      ];

      input-field = [
        {
          size = "300, 50";
          outline_thickness = 2;
          dots_size = 0.2;
          dots_spacing = 0.3;
          dots_center = true;
          outer_color = "rgba(122, 162, 247, 0.5)";
          inner_color = "rgba(26, 27, 46, 0.9)";
          font_color = "#c0caf5";
          fade_on_empty = false;
          placeholder_text = "";
          rounding = 12;
          position = "0, -80";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}
