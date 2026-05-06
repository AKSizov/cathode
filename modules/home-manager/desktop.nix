{ pkgs, lib, inputs, ... }:
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

  # Noctalia handles bar, notifications, lock screen, OSD, launcher, and clipboard
  programs.noctalia-shell = {
    enable = true;
    package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
    settings = {
      settingsVersion = 0;
      bar = {
        widgets = {
          left = [
            { id = "Launcher"; }
            { id = "ActiveWindow"; }
          ];
          center = [
            { id = "Workspace"; }
          ];
          right = [
            { id = "SystemMonitor"; }
            { id = "Tray"; }
            { id = "NotificationHistory"; }
            { id = "Battery"; }
            { id = "Volume"; }
            { id = "Brightness"; }
            { id = "ControlCenter"; }
          ];
        };
      };
      general = {
        telemetryEnabled = false;
        lockOnSuspend = true;
        lockScreenAnimations = true;
      };
      appLauncher = {
        enableClipboardHistory = true;
      };
      plugins = {
        colorSchemes = {
          predefinedScheme = "Tokyo Night";
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


  services.wlsunset = {
    enable = true;
    sunset = "20:00";
    sunrise = "8:00";
  };

  # relies on programs.dconf.enable = true;
  services.easyeffects.enable = true;

  # Noctalia handles bar, notifications, lock screen, OSD, launcher, and clipboard

  # ============================================================================
  # Stylix - Home Manager Level
  # ============================================================================
  # Base theming is configured at the NixOS level in
  # modules/nixos/desktop/stylix.nix and inherited by Home Manager.
  # Browser profile names must be declared here (HM-level option).

  stylix.targets = {
    firefox.profileNames = [ "default" ];
    zen-browser.profileNames = [ "default" ];
  };
}
