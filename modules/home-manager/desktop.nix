{ pkgs, lib, inputs, ... }:
{
  # ============================================================================
  # Desktop Home Manager Configuration
  # ============================================================================
  # User environment for desktop systems with GUI applications
  
  imports = [
    inputs.zen-browser.homeModules.beta
    ./base.nix
    ./hyprland.nix
    ./waybar.nix
    ./dunst.nix
    ./hyprlock.nix

  ];

  # ============================================================================
  # Desktop Packages
  # ============================================================================

  home.packages = with pkgs; [
    # Creative & Design
    gimp3
    openscad
    
    # Media & Entertainment
    parsec-bin
    moonlight-qt
    
    # Productivity
    obsidian
    
    # 3D Printing
    orca-slicer
    prusa-slicer

    # Icon theme for rofi
    papirus-icon-theme

    # CLI tools
    libnotify  # notify-send for dunst
  ];

  # ============================================================================
  # GTK Theme Configuration
  # ============================================================================

  gtk = {
    enable = true;
    cursorTheme = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };
  };

  # Qt theming is handled by Stylix (uses qtct platform)
  qt.enable = true;

  # ============================================================================
  # Wayland Environment
  # ============================================================================

  # Enable Wayland for Electron apps (VSCode, etc.)
  home.sessionVariables.NIXOS_OZONE_WL = "1";

  # ============================================================================
  # Desktop Applications
  # ============================================================================

  programs.kitty.enable = true;
  programs.firefox.enable = true;
  programs.mpv.enable = true;
  programs.yt-dlp.enable = true;

  programs.zen-browser = {
    enable = true;
    policies = {
      AutofillAddressEnabled = false;
      AutofillCreditCardEnabled = false;
      DisableAppUpdate = true;
      DisableFeedbackCommands = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
      NoDefaultBookmarks = true;
      OfferToSaveLogins = false;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
    };
    profiles."default" = {
      # containersForce = true;
      # containers = {
      #   Shopping = {
      #     color = "purple";
      #     icon = "cart";
      #     id = 1;
      #   };
      #   Banking = {
      #     color = "green";
      #     icon = "dollar";
      #     id = 2;
      #   };
      # };
      settings = {
        "browser.tabs.warnOnClose" = false;
        "browser.download.panel.shown" = false;
        "zen.tabs.vertical.right-side" = true;
      };
      keyboardShortcuts = builtins.genList (n: {
        id = "zen-workspace-switch-${toString (n + 1)}";
        key = toString (n + 1);
        modifiers.control = true;
      }) 9;
      # Fails activation on schema changes to detect potential regressions
      # Find this in about:config or prefs.js of your profile
      keyboardShortcutsVersion = 14;
    };
  };

  
  programs.rofi = {
    enable = true;
    # rofi-wayland was merged into rofi as of nixpkgs 25.11
    plugins = [ pkgs.rofi-calc ];
    extraConfig = {
      modi = "drun,power:${pkgs.writeShellScript "power-menu" ''
        if [ -z "''${ROFI_RETV:-}" ]; then
          echo "Lock"
          echo "Logout"
          echo "Suspend"
          echo "Hibernate"
          echo "Reboot"
          echo "Shutdown"
        else
          case "$@" in
            Lock) loginctl lock-session ;;
            Logout) loginctl terminate-user "$USER" ;;
            Suspend) systemctl suspend ;;
            Hibernate) systemctl hibernate ;;
            Reboot) systemctl reboot ;;
            Shutdown) systemctl poweroff ;;
          esac
        fi
      ''}";
      show-icons = true;
      icon-theme = "Papirus-Dark";
      drun-display-format = "{name}";
      disable-history = false;
      sidebar-mode = false;
      matching = "fuzzy";
    };
    theme = ./rofi-theme.rasi;
  };

  # VSCode with FHS environment for extension compatibility
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      saoudrizwan.claude-dev
      ms-vscode.remote-explorer
    ];

    profiles.default.userSettings = {
      "files.autoSave" = "afterDelay";
      "editor.wordWrap" = "on";
      "nix.enableLanguageServer" = true;
      "editor.minimap.enabled" = false;
      "workbench.panel.defaultLocation" = "right";
      "workbench.editor.showTabs" = "none";
      "update.showReleaseNotes" = false;
      "chat.disableAIFeatures" = true;
      
      # Terminal profiles
      "terminal.integrated.profiles.linux" = {
        "bash (agent)" = {
          "path" = "bash";
          "args" = [ "--noprofile" "--norc" ];
          "icon" = "terminal-bash";
        };
      };
      "terminal.integrated.defaultProfile.linux" = "bash (agent)";
    };
  };

  # ============================================================================
  # Desktop Services
  # ============================================================================

  # On-screen volume/brightness overlay
  services.swayosd.enable = true;

  # Clipboard history manager (systemd services auto-start wl-paste watchers)
  services.cliphist.enable = true;

  # Blue light filter
  services.wlsunset = {
    enable = true;
    sunset = "20:00";
    sunrise = "8:00";
  };

  # relies on programs.dconf.enable = true;
  services.easyeffects.enable = true;

  # TODO: Add eww/ags desktop widgets for system stats overlay
  # Consider: eww (Elkowars Wacky Widgets) with Tokyo Night themed CSS

  # ============================================================================
  # Stylix - Home Manager Level
  # ============================================================================
  # Base theming is configured at the NixOS level in
  # modules/nixos/desktop/stylix.nix and inherited by Home Manager.
  # Browser profile names must be declared here (HM-level option).

  stylix.targets = {
    firefox.profileNames = [ "default" ];
    zen-browser.profileNames = [ "default" ];
    rofi.enable = false;  # Using custom Tokyo Night theme instead
    hyprlock.enable = false;  # Using custom hyprlock config with specific input field styling
    dunst.enable = false;  # Using custom Tokyo Night dunst config
  };
}
