{ pkgs, ... }:
{
  # ============================================================================
  # Hyprland Window Manager Configuration
  # ============================================================================

  home.packages = with pkgs; [
    brightnessctl
    playerctl
  ];

  wayland.windowManager.hyprland = {
    enable = true;

    settings = {
      # Monitor configuration
      monitor = [ ", preferred, auto, auto" ];

      # Environment variables
      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
      ];

      # General settings
      general = {
        gaps_in = 8;
        gaps_out = 16;
        border_size = 2;
        resize_on_border = true;
        allow_tearing = false;
        layout = "dwindle";
      };

      # Decoration
      decoration = {
        rounding = 10;
        active_opacity = 1.0;
        inactive_opacity = 1.0;
        dim_inactive = true;
        dim_strength = 0.05;

        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
        };

        blur = {
          enabled = true;
          size = 8;
          passes = 3;
          vibrancy = 0.1696;
        };
      };

      # Animations
      animations = {
        enabled = true;

        bezier = [
          "easeOutQuint, 0.23, 1, 0.32, 1"
          "easeInOutCubic, 0.65, 0.05, 0.36, 1"
          "linear, 0, 0, 1, 1"
          "quick, 0.15, 0, 0.1, 1"
        ];

        animation = [
          "global, 1, 6, default"
          "border, 1, 4, easeOutQuint"
          "windows, 1, 3, easeOutQuint"
          "windowsIn, 1, 3, easeOutQuint, popin 87%"
          "windowsOut, 1, 1.5, linear, popin 87%"
          "fadeIn, 1, 3, quick"
          "fadeOut, 1, 3, quick"
          "fade, 1, 3, quick"
          "layers, 1, 3, easeOutQuint"
          "layersIn, 1, 3, easeOutQuint, fade"
          "layersOut, 1, 1.5, linear, fade"
          "fadeLayersIn, 1, 3, quick"
          "fadeLayersOut, 1, 1.5, quick"
          "workspaces, 1, 3, quick, fade"
          "workspacesIn, 1, 2, quick, fade"
          "workspacesOut, 1, 3, quick, fade"
        ];
      };

      # Layouts
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      master = {
        new_status = "master";
      };

      # Misc
      misc = {
        force_default_wallpaper = -1;
      };

      # Variables
      "$mainMod" = "SUPER";
      "$terminal" = "kitty";
      "$fileManager" = "nautilus";
      "$menu" = "rofi -show drun";
      "$lock" = "systemctl hibernate";

      # Key bindings — App launchers
      bind = [
        "$mainMod, T, exec, $terminal"
        "$mainMod, Return, exec, $terminal"
        "$mainMod, R, exec, $menu"
        "$mainMod, L, exec, $lock"

        # Window management
        "$mainMod, Q, killactive"
        "$mainMod, M, exit"
        "$mainMod, Space, togglefloating"
        "$mainMod, F, fullscreen"

        # Focus movement
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"

        # Workspace switching
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        # Move window to workspace
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"

        # Special workspace (scratchpad)
        "$mainMod, S, togglespecialworkspace, magic"
        "$mainMod SHIFT, S, movetoworkspace, special:magic"

        # Magic terminal scratchpad
        "$mainMod, grave, exec, [workspace special:term; float; size 50% 600; move 25% 16] kitty"

        # Workspace scroll
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"

        # Monitor toggle keybinds (from custom config)
        "$mainMod, F1, exec, hyprctl keyword monitor HDMI-A-3, preferred, auto, 1"
        "$mainMod, F2, exec, hyprctl keyword monitor HDMI-A-3, 1920x1080, 0x0, 1"
        "$mainMod, F3, exec, hyprctl reload"
      ];

      # Mouse bindings
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      # Window rules
      windowrulev2 = [
        "suppressevent maximize, class:.*"
        "nofocus, class:^$, title:^$, xwayland:1, floating:1, fullscreen:0, pinned:0"
      ];
    };

    # Media keys, lid switch, input/device config, and autostart
    # These use bindl/bindel and input/device blocks that are cleaner in extraConfig
    extraConfig = ''
      # Media Keys
      bindel = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
      bindel = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
      bindel = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
      bindel = , XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

      # Brightness
      bindel = , XF86MonBrightnessUp, exec, brightnessctl s 10%+
      bindel = , XF86MonBrightnessDown, exec, brightnessctl s 10%-

      # Player controls
      bindl = , XF86AudioNext, exec, playerctl next
      bindl = , XF86AudioPause, exec, playerctl play-pause
      bindl = , XF86AudioPlay, exec, playerctl play-pause
      bindl = , XF86AudioPrev, exec, playerctl previous

      # Lid switch (laptop)
      bindl = , switch:off:Apple SMC power/lid events, exec, hyprctl keyword monitor "eDP-1, preferred, auto, auto"
      bindl = , switch:on:Apple SMC power/lid events, exec, hyprctl keyword monitor "eDP-1, disable"

      # Input configuration
      input {
          kb_layout = us
          kb_variant = dvorak
          kb_options = ctrl:nocaps
          accel_profile = flat
          follow_mouse = 1
          sensitivity = 0

          touchpad {
              natural_scroll = false
          }
      }

      # Device-specific config
      device {
          name = apple-spi-trackpad
          natural_scroll = true
          accel_profile = adaptive
      }

      # Autostart
      exec-once = hyprctl setcursor Bibata-Modern-Classic 24
      exec-once = systemctl start --user hyprpolkitagent
    '';
  };
}
