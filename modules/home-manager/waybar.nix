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
      modules-right = [ "idle_inhibitor" "pulseaudio" "network" "custom/cpu" "custom/memory" "battery" "tray" ];

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
          activated = "󰒳";
          deactivated = "󰒲";
        };
        tooltip-format-activated = "Caffeine mode — screen won't dim";
        tooltip-format-deactivated = "Screen will dim when idle";
      };

      clock = {
        format = "󰥔  {:%H:%M}";
        format-alt = "󰃭  {:%A, %B %d}";
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
        format-muted = "󰖁  muted";
        format-icons = {
          headphone = "󰋋";
          headset = "󰋎";
          default = [ "󰕿" "󰖀" "󰕾" ];
        };
        on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
      };

      network = {
        format-wifi = "󰤨  {essid}";
        format-ethernet = "󰈀  {ipaddr}";
        format-disconnected = "󰤭  offline";
        tooltip-format-wifi = "WiFi: {essid} ({signalStrength}%)\nIP: {ipaddr}\nFreq: {frequency} GHz";
        tooltip-format-ethernet = "IP: {ipaddr}\nGateway: {gwaddr}";
      };

      # CPU with Unicode progress bar
      "custom/cpu" = {
        format = "󰻠 {}";
        exec = let
          script = pkgs.writeShellScript "waybar-cpu" ''
            read -r _ user nice system idle iowait irq softirq steal _ _ < /proc/stat
            prev_idle=$((idle + iowait))
            prev_total=$((user + nice + system + idle + iowait + irq + softirq + steal))
            sleep 1
            read -r _ user nice system idle iowait irq softirq steal _ _ < /proc/stat
            cur_idle=$((idle + iowait))
            cur_total=$((user + nice + system + idle + iowait + irq + softirq + steal))
            diff_idle=$((cur_idle - prev_idle))
            diff_total=$((cur_total - prev_total))
            diff_usage=$((diff_total - diff_idle))
            if [ $diff_total -gt 0 ]; then
              pct=$(( 100 * diff_usage / diff_total ))
            else
              pct=0
            fi
            filled=$(( pct / 10 ))
            empty=$(( 10 - filled ))
            bar=""
            for ((i=0; i<filled; i++)); do bar+="█"; done
            for ((i=0; i<empty; i++)); do bar+="░"; done
            echo "{\"text\": \"$bar ''${pct}%\", \"class\": \"cpu-''${pct}\"}"
          '';
        in "${script}";
        return-type = "json";
        interval = 2;
        tooltip = false;
      };

      # Memory with Unicode progress bar
      "custom/memory" = {
        format = "󰍛 {}";
        exec = let
          script = pkgs.writeShellScript "waybar-mem" ''
            read -r _ total used _ _ _ _ _ _ _ _ _ < <(free --mega | grep Mem)
            if [ "$total" -gt 0 ]; then
              pct=$(( 100 * used / total ))
            else
              pct=0
            fi
            filled=$(( pct / 10 ))
            empty=$(( 10 - filled ))
            bar=""
            for ((i=0; i<filled; i++)); do bar+="█"; done
            for ((i=0; i<empty; i++)); do bar+="░"; done
            echo "{\"text\": \"$bar ''${pct}%\", \"class\": \"mem-''${pct}\"}"
          '';
        in "${script}";
        return-type = "json";
        interval = 2;
        tooltip = false;
      };

      battery = {
        states = {
          good = 95;
          warning = 30;
          critical = 15;
        };
        format = "{icon}  {capacity}%";
        format-charging = "󰂄  {capacity}%";
        format-plugged = "󰚥  {capacity}%";
        format-icons = [ "󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
      };

      tray = {
        icon-size = 16;
        spacing = 8;
      };
    };
  };
}
