{ pkgs, ... }:
{
  # ============================================================================
  # Dunst — Notification Daemon
  # ============================================================================
  # Replaced SwayNC — dunst's ini-style config is far more reliable than
  # swaync's GTK CSS which kept breaking across version updates.

  services.dunst = {
    enable = true;

    settings = {
      global = {
        # Display
        monitor = 0;
        follow = "mouse";
        geometry = "400x5-20+40";
        indicate_hidden = "yes";
        shrink = "no";
        transparency = 10;
        notification_height = 0;
        separator_height = 2;
        padding = 14;
        horizontal_padding = 14;
        text_icon_padding = 12;
        corner_radius = 12;
        frame_width = 2;
        frame_color = "#565f89";
        separator_color = "frame";

        # Sort by urgency
        sort = "yes";

        # Idle behavior
        idle_threshold = 120;

        # Font
        font = "Inter 13";

        # Icons
        icon_position = "left";
        min_icon_size = 32;
        max_icon_size = 48;
        icon_path = "/usr/share/icons/Papirus-Dark/16x16/status/:/usr/share/icons/Papirus-Dark/16x16/devices/";

        # Progress bar
        progress_bar = true;
        progress_bar_height = 6;
        progress_bar_frame_width = 1;
        progress_bar_min_width = 150;
        progress_bar_max_width = 300;
        progress_bar_corners_radius = 4;

        # Misc
        markup = "full";
        format = "<b>%s</b>\\n%b";
        alignment = "left";
        vertical_alignment = "center";
        show_age_threshold = 60;
        word_wrap = "yes";
        ellipsize = "middle";
        ignore_newline = "no";
        stack_duplicates = true;
        hide_duplicate_count = false;
        show_indicators = "yes";

        # Mouse
        mouse_left_click = "do_action, close_current";
        mouse_middle_click = "close_all";
        mouse_right_click = "close_current";
      };

      # Tokyo Night — Low urgency
      urgency_low = {
        background = "#1a1b26cc";
        foreground = "#c0caf5";
        frame_color = "#565f89";
        timeout = 5;
        # No icon override — uses iconTheme above
      };

      # Tokyo Night — Normal urgency
      urgency_normal = {
        background = "#1a1b26cc";
        foreground = "#c0caf5";
        frame_color = "#7aa2f7";
        timeout = 8;
      };

      # Tokyo Night — Critical urgency
      urgency_critical = {
        background = "#1a1b26cc";
        foreground = "#f7768e";
        frame_color = "#f7768e";
        timeout = 0;
      };

      # Per-app overrides
      vol_brightness = {
        appname = "volume";
        body = " ";
        timeout = 3;
      };
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };
}
