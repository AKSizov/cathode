{ pkgs, ... }:
{
  # ============================================================================
  # Waybar — Status Bar
  # ============================================================================

  programs.waybar = {
    enable = true;
    style = builtins.readFile ./waybar-style.css;

    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 36;
      margin = "8 12 0 12";

      modules-left = [ "hyprland/workspaces" "hyprland/window" ];
      modules-center = [ "clock" ];
      modules-right = [ "idle_inhibitor" "pulseaudio" "network" "cpu" "memory" "battery" "tray" ];

      "hyprland/workspaces" = {
        format = "{icon}";
        format-icons = {
          "1" = "一";
          "2" = "二";
          "3" = "三";
          "4" = "四";
          "5" = "五";
          "6" = "六";
          "7" = "七";
          "8" = "八";
          "9" = "九";
          "10" = "十";
          default = "○";
          active = "●";
          urgent = "!";
        };
        persistent-workspaces = {
          "*" = 5;
        };
      };

      "hyprland/window" = {
        format = "{title}";
        max-length = 40;
        separate-outputs = true;
      };

      idle_inhibitor = {
        format = "{icon}";
        format-icons = {
          activated = "";
          deactivated = "";
        };
        tooltip-format-activated = "Idle inhibitor active";
        tooltip-format-deactivated = "Idle inhibitor inactive";
      };

      clock = {
        format = "  {:%H:%M}";
        format-alt = "  {:%A, %B %d}";
        tooltip-format = "<tt><small>{calendar}</small></tt>";
        calendar = {
          mode = "year";
          mode-mon-col = 3;
          weeks-pos = "right";
          on-scroll = 1;
          on-click-right = "mode";
          format = {
            months = "<span color='#7aa2f7'><b>{}</b></span>";
            days = "<span color='#c0caf5'><b>{}</b></span>";
            weeks = "<span color='#bb9af7'><b>W{}</b></span>";
            weekdays = "<span color='#7dcfff'><b>{}</b></span>";
            today = "<span color='#f7768e'><b><u>{}</u></b></span>";
          };
        };
      };

      pulseaudio = {
        format = "{icon}  {volume}%";
        format-muted = "  muted";
        format-icons = {
          headphone = "";
          headset = "";
          default = [ "" "" "" ];
        };
        on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
      };

      network = {
        format-wifi = "  {essid}";
        format-ethernet = "  {ipaddr}";
        format-disconnected = "  offline";
        tooltip-format-wifi = "WiFi: {essid} ({signalStrength}%)\nIP: {ipaddr}\nFreq: {frequency} GHz";
        tooltip-format-ethernet = "IP: {ipaddr}\nGateway: {gwaddr}";
      };

      cpu = {
        format = "  {usage}%";
        tooltip = false;
      };

      memory = {
        format = "  {}%";
        tooltip-format = "Used: {used:0.1f}G / {total:0.1f}G";
      };

      battery = {
        states = {
          good = 95;
          warning = 30;
          critical = 15;
        };
        format = "{icon}  {capacity}%";
        format-charging = "  {capacity}%";
        format-plugged = "  {capacity}%";
        format-icons = [ "" "" "" "" "" ];
      };

      tray = {
        icon-size = 16;
        spacing = 8;
      };
    };
  };
}
