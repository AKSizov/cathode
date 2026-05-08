{ config, pkgs, lib, inputs, ... }:
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
    settings = {
      general = {
        showChangelogOnStartup = lib.mkForce false;
        lockScreenAnimations = lib.mkForce true;
        lockOnSuspend = lib.mkForce true; # Must be explicit — jsonFormat.type replaces entire attrset
      };
      brightness = {
        enableDdcSupport = lib.mkForce true;
      };
      idle = {
        enabled = lib.mkForce true;
        screenOffTimeout = lib.mkForce 300;
        lockTimeout = lib.mkForce 360;
        suspendTimeout = lib.mkForce 0;
        fadeDuration = lib.mkForce 5;
      };
      desktopWidgets = {
        enabled = lib.mkForce true;
      };
      templates = {
        activeTemplates = lib.mkForce [
          { id = "kitty"; active = true; }
        ];
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
      keyboardShortcutsVersion = 17;
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


  # relies on programs.dconf.enable = true;
  services.easyeffects.enable = true;

  # Noctalia handles bar, notifications, lock screen, OSD, launcher, and clipboard

  # ============================================================================
  # Lock-on-Suspend Workaround
  # ============================================================================
  # Noctalia's built-in lockOnSuspend is broken for externally-triggered suspend
  # (lid close, power button) — see https://github.com/noctalia-dev/noctalia-shell/issues/2036
  # PR #2176 fixes this via DBus monitoring but hasn't been merged yet.
  #
  # User-level sleep.target doesn't activate on system suspend (it's system-level),
  # so a WantedBy=sleep.target user service never fires. The only reliable approach
  # from a user session is to monitor DBus for PrepareForSleep — same as hypridle
  # and the Noctalia PR.

  systemd.user.services.noctalia-lock-on-suspend = {
    Unit = {
      Description = "Lock Noctalia screen on suspend via DBus";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = toString (pkgs.writeShellScript "noctalia-suspend-monitor" ''
        ${lib.getExe' pkgs.glib "gdbus"} monitor --system \
          --dest org.freedesktop.login1 \
          --object-path /org/freedesktop/login1 2>/dev/null \
          | ${lib.getExe' pkgs.coreutils "stdbuf"} -oL ${lib.getExe' pkgs.gnugrep "grep"} --line-buffered PrepareForSleep \
          | while IFS= read -r line; do
              if echo "$line" | ${lib.getExe' pkgs.gnugrep "grep"} -q "true"; then
                ${config.programs.noctalia-shell.package}/bin/noctalia-shell ipc call lockScreen lock
              fi
            done
      '');
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };



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
