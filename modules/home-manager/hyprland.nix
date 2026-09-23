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

    # Pin to hyprlang format — stateVersion 26.05+ defaults to "lua"
    # which requires a completely different settings structure.
    # Migrate when the Lua config generation is stable.
    configType = "hyprlang";

    settings = {
      # DP-1: Sceptre M34 3440x1440 — highres picks highest resolution + refresh
      # Wildcard: all other monitors default to preferred mode, scale 1
      # (first matching entry wins — specific monitors must be listed BEFORE this)
      monitor = [
        "DP-1, highres, auto, 1"
        ", preferred, auto, 1"
      ];

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
        dim_strength = 0.15;

        shadow = {
          enabled = true;
          range = 12;
          render_power = 3;
          color = "rgba(0a0a0fee)";
        };

        blur = {
          enabled = true;
          size = 12;
          passes = 3;
          vibrancy = 0.2;
        };
      };

      # Animations — minimal, consistent. Parent nodes set defaults;
      # only override children when the style or speed should differ.
      # Curves: easeOutQuint for UI, spring for window open/close.
      animations = {
        enabled = true;

        bezier = [
          "easeOutQuint, 0.23, 1, 0.32, 1"
          "spring, 0.3, 1.2, 0.5, 1"
          "linear, 0, 0, 1, 1"
        ];

        animation = [
          "global, 1, 5, easeOutQuint"
          "border, 1, 5, easeOutQuint"
          "windows, 1, 4, easeOutQuint"
          "windowsIn, 1, 4, spring, popin 87%"
          "windowsOut, 1, 3, easeOutQuint, popin 87%"
          "fade, 1, 3, easeOutQuint"
          "layers, 1, 3, easeOutQuint"
          "layersIn, 1, 3, easeOutQuint, fade"
          "layersOut, 1, 2, linear, fade"
          "workspaces, 1, 4, easeOutQuint, slidefade 15%"
          "workspacesIn, 1, 4, easeOutQuint, slidefade 15%"
          "workspacesOut, 1, 3, easeOutQuint, fade"
        ];
      };

      # Layouts
      dwindle = {
        preserve_split = true;
        smart_split = true;
        smart_resizing = true;
        force_split = 0;
        split_width_multiplier = 1.0;
      };

      master = {
        new_status = "master";
      };

      # Misc
      misc = {
        force_default_wallpaper = -1;
        disable_hyprland_logo = true;
      };

      # Variables
      "$mainMod" = "SUPER";
      "$terminal" = "kitty";
      "$fileManager" = "nautilus";

      # Key bindings — App launchers
      bind = [
        "$mainMod, T, exec, $terminal"
        "$mainMod, Return, exec, $terminal"
        "$mainMod, L, exec, noctalia msg panel-toggle session"

        # Window management
        "$mainMod, Q, killactive"
        "$mainMod, M, exit"
        # Dwindle layout control
        "$mainMod, V, layoutmsg, togglesplit"
        # Noctalia shell
        "$mainMod, Space, exec, noctalia msg panel-toggle launcher"
        "$mainMod, S, exec, noctalia msg panel-toggle control-center"
        "$mainMod, comma, exec, noctalia msg settings-toggle"
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

        # Layout toggle — switch between Dvorak and QWERTY (useful for games)
        "$mainMod, F12, exec, hyprctl switchxkblayout current next"

        # Workspace scroll
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"

        # Monitor refresh-rate keybinds (Sceptre M34, DP-1)
        "$mainMod, F1, exec, hyprctl keyword monitor DP-1, 3440x1440@240, auto, 1"
        "$mainMod, F2, exec, hyprctl keyword monitor DP-1, 3440x1440@144, auto, 1"
        "$mainMod, F3, exec, hyprctl reload"
      ];

      # Mouse bindings
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      # Window rules
      windowrule = [
        # Dialog suppression
        "suppress_event maximize, match:class .*"
        "no_initial_focus true, match:class ^$, match:title ^$, match:xwayland 1, match:float 1, match:fullscreen 0, match:pin 0"

        # Floating apps
        "float true, match:class ^(org.kde.polkit-kde-authentication-agent-1)$"
        "float true, match:class ^(xdg-desktop-portal-gtk)$"
        "float true, match:class ^(easyeffects)$"
        "size 900 600, match:class ^(easyeffects)$"

        # Noctalia settings window — float instead of tiling (per v5 docs)
        "float true, match:class ^(dev.noctalia.Noctalia)$"
        "size 1080 920, match:class ^(dev.noctalia.Noctalia)$"

        # File dialogs
        "float true, match:title ^(Open File|Save File|Open Folder)$"

        # Picture-in-Picture
        "float true, match:title ^(Picture-in-Picture)$"
        "pin true, match:title ^(Picture-in-Picture)$"
        "size 480 270, match:title ^(Picture-in-Picture)$"
      ];

      # Blur Noctalia surfaces (bar, notifications, dock, panels, OSD, switcher).
      # Per v5 docs; Hyprland's layer animations are disabled for these so they
      # don't fight Noctalia's own.
      layerrule = [
        "noanim, namespace:^(noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher))$"
        "ignorealpha 0.5, namespace:^(noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher))$"
        "blur, namespace:^(noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher))$"
        "blurpopups, namespace:^(noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher))$"
      ];
    };

    # Media keys, lid switch, input/device config, and autostart
    # These use bindl/bindel and input/device blocks that are cleaner in extraConfig
    # See ../../dotfiles/hyprland-extra.conf for the standalone config
    extraConfig = builtins.readFile ../../dotfiles/hyprland-extra.conf;
  };
}
