{ pkgs, ... }:
{
  # ============================================================================
  # Hyprland Window Manager Configuration
  # ============================================================================

  home.packages = with pkgs; [
    playerctl
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    # MUST be false when using UWSM (NixOS-level withUWSM = true)
    # UWSM handles systemd session management itself
    systemd.enable = false;

    settings = {
      # Monitor configuration
      monitor = [ ", preferred, auto, 1" ];

      # Environment variables
      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
      ];

      # General settings
      general = {
        gaps_in = 6;
        gaps_out = 12;
        border_size = 2;
        resize_on_border = true;
        allow_tearing = false;
        layout = "dwindle";
      };

      # Decoration
      decoration = {
        rounding = 12;
        active_opacity = 1.0;
        inactive_opacity = 1.0;
        dim_inactive = true;
        dim_strength = 0.1;

        shadow = {
          enabled = true;
          range = 8;
          render_power = 3;
        };

        blur = {
          enabled = true;
          size = 10;
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
          "spring, 0.3, 1.2, 0.5, 1"
        ];

        animation = [
          "global, 1, 6, default"
          "border, 1, 4, easeOutQuint"
          "windows, 1, 3, easeOutQuint"
          "windowsIn, 1, 4, spring, popin 87%"
          "windowsOut, 1, 2, easeOutQuint, popin 87%"
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

      # Key bindings — App launchers
      bind = [
        "$mainMod, T, exec, $terminal"
        "$mainMod, Return, exec, $terminal"
        "$mainMod, L, exec, noctalia-shell ipc call lockScreen lock"

        # Window management
        "$mainMod, Q, killactive"
        "$mainMod, M, exit"
        # Noctalia shell
        "$mainMod, Space, exec, noctalia-shell ipc call launcher toggle"
        "$mainMod, S, exec, noctalia-shell ipc call controlCenter toggle"
        "$mainMod, comma, exec, noctalia-shell ipc call settings toggle"
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
        # Dialog suppression
        "suppressevent maximize, class:.*"
        "nofocus, class:^$, title:^$, xwayland:1, floating:1, fullscreen:0, pinned:0"

        # Floating apps
        "float, class:^(org.kde.polkit-kde-authentication-agent-1)$"
        "float, class:^(xdg-desktop-portal-gtk)$"
        "float, class:^(easyeffects)$"
        "size 900 600, class:^(easyeffects)$"

        # File dialogs
        "float, title:^(Open File|Save File|Open Folder)$"

        # Picture-in-Picture
        "float, title:^(Picture-in-Picture)$"
        "pin, title:^(Picture-in-Picture)$"
        "size 480 270, title:^(Picture-in-Picture)$"
      ];
    };

    # Media keys, lid switch, input/device config, layer rules, and autostart
    extraConfig = ''
      # Player controls
      bindl = , XF86AudioNext, exec, playerctl next
      bindl = , XF86AudioPause, exec, playerctl play-pause
      bindl = , XF86AudioPlay, exec, playerctl play-pause
      bindl = , XF86AudioPrev, exec, playerctl previous

      $ipc = noctalia-shell ipc call

      # Volume & Brightness (via Noctalia IPC)
      bindel = , XF86AudioRaiseVolume, exec, $ipc volume increase
      bindel = , XF86AudioLowerVolume, exec, $ipc volume decrease
      bindl = , XF86AudioMute, exec, $ipc volume muteOutput
      bindel = , XF86MonBrightnessUp, exec, $ipc brightness increase
      bindel = , XF86MonBrightnessDown, exec, $ipc brightness decrease

      # Lid switch (laptop)
      bindl = , switch:off:Apple SMC power/lid events, exec, hyprctl keyword monitor "eDP-1, preferred, auto, auto"
      bindl = , switch:on:Apple SMC power/lid events, exec, hyprctl keyword monitor "eDP-1, disable"

      # Idle dim — gently dim all windows when idle, restore on activity
      bindl = , idle:in:120, exec, hyprctl keyword decoration:active_opacity 0.85 && hyprctl keyword decoration:inactive_opacity 0.75
      bindl = , idle:out:120, exec, hyprctl keyword decoration:active_opacity 1.0 && hyprctl keyword decoration:inactive_opacity 1.0

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

      # Noctalia layer rules — blur for bar and panels
      layerrule = blur, noctalia-background-.*
      layerrule = ignorealpha 0.5, noctalia-background-.*

      # Autostart
      exec-once = hyprctl setcursor Bibata-Modern-Classic 24
      exec-once = systemctl start --user hyprpolkitagent
      exec-once = noctalia-shell
    '';
  };
}
