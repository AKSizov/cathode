{ config, pkgs, inputs, ... }:
{
  # ============================================================================
  # Desktop Home Manager Configuration
  # ============================================================================
  # User environment for desktop systems with GUI applications
  
  imports = [
    inputs.zen-browser.homeModules.beta
    inputs.noctalia.homeModules.default
    ./base.nix
    ./hyprland.nix
  ];

  # Noctalia v5 — desktop shell: bar, notifications, lock, OSD, launcher, clipboard
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    settings = {
      shell.setup_wizard_enabled = false;
      theme = {
        mode = "dark";
        source = "builtin";
        builtin = "Tokyo-Night";
      };
      idle = {
        behavior = {
          lock = {
            timeout = 360;
            command = "noctalia:session lock";
            enabled = true;
          };
          "screen-off" = {
            timeout = 300;
            command = "noctalia:dpms-off";
            resume_command = "noctalia:dpms-on";
            enabled = true;
          };
        };
      };
    };
  };

  # ============================================================================
  # Desktop Packages
  # ============================================================================

  home.packages = with pkgs; [
    # Creative & Design
    gimp3
    openscad

    # Electronics / EDA
    kicad
    turbocase

    # Media & Entertainment
    parsec-bin
    moonlight-qt
    
    # Productivity
    obsidian
    
    # 3D Printing
    orca-slicer
    prusa-slicer
  ];

  # ============================================================================
  # GTK Theme Configuration
  # ============================================================================

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    cursorTheme = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };
  };

  # Qt theming — Noctalia's syncGsettings syncs GTK colors;
  # qtct platform theme is still enabled for basic Qt integration
  qt.enable = true;

  # ============================================================================
  # Wayland Environment
  # ============================================================================

  # Enable Wayland for Electron apps (VSCode, etc.)
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    # Cursor theme — previously set by Stylix, now explicit
    XCURSOR_THEME = "Bibata-Modern-Classic";
    XCURSOR_SIZE = "24";
  };

  # ============================================================================
  # Desktop Applications
  # ============================================================================

  programs.kitty = {
    enable = true;
    # Use Noctalia's generated theme instead of Stylix
    extraConfig = ''
      include themes/noctalia.conf
    '';
  };
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
      keyboardShortcutsVersion = 19;
    };
  };



  # VSCodium
  programs.vscodium = {
    enable = true;
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


  # relies on programs.dconf.enable = true;
  services.easyeffects.enable = true;
}
