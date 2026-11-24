{ pkgs, ... }:
{
  # ============================================================================
  # Gaming Module
  # ============================================================================
  # Core gaming support, controller drivers, system optimizations, and tools

  # --- Steam ---
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;          # Steam Remote Play
    localNetworkGameTransfers.openFirewall = true; # LAN game transfers
    protontricks.enable = true;              # Winetricks wrapper for Proton prefixes
  };

  # --- 32-bit graphics support ---
  # Required for 32-bit and Proton games — without this, most games won't launch
  hardware.graphics.enable32Bit = true;

  # --- Controller support ---
  hardware.xpadneo.enable = true;           # Xbox Bluetooth controller (better than in-kernel xpad)

  # Add user to gamemode group so they can request it
  users.users.user.extraGroups = [ "gamemode" ];

  # --- Games & launchers ---
  # Java runtimes so Modrinth doesn't download its own (broken on NixOS)
  environment.systemPackages = with pkgs; [
    modrinth-app                              # Minecraft launcher — polished UI, built-in modpack browsing
    jdk8                                     # Minecraft <=1.16.5
    jdk17                                    # Minecraft 1.17–1.20.4
    jdk21                                    # Minecraft 1.20.5+
    mangohud                                 # FPS/frame timing overlay (run games with `mangohud %command%`)
    gamescope                                # Micro-compositor for lag-free gaming (use: gamescope --gamemode -- %command%)
  ];

  services.flatpak.enable = true; 

  # --- OpenNOW (open-source GeForce NOW client) ---
  # The release AppImage lives OUTSIDE the store (~/Applications/) and updates
  # itself via the app's Ed25519-verified in-app updater (Settings → Updates,
  # stable/nightly channel) — no more version/hash bumps in this file.
  # binfmt routes any AppImage execution through appimage-run (appimage-exec.sh
  # exports APPIMAGE=<realpath of the file> so the updater can replace it, and
  # unpacks to ~/.cache/appimage-run/<sha256>, re-keyed after each update).
  # The FHS env carries nixpkgs libva + intel-media-driver: the AppImage's
  # AppRun libva-detection hook (ldconfig -p) then picks ABI-matched nixpkgs
  # libva instead of the bundled Ubuntu libva 2.20 (which cannot load newer-ABI
  # VA drivers — hw decode silently falls back to software; upstream docs:
  # linux-video-backends.md). This is the same mechanism as the old wrapType2
  # package, minus the read-only store pin that broke the in-app updater.
  # Fallback if the in-app updater ever misbehaves: `appimageupdate` (nixpkgs)
  # applies the release's .AppImage.zsync sidecar in place.
  programs.appimage = {
    enable = true;
    binfmt = true;
    package = pkgs.appimage-run.override {
      extraPkgs = p: [
        p.libva
        p.intel-media-driver
      ];
    };
  };

  # Shader cache — prevent stutter from recompilation on repeat plays
  environment.sessionVariables = {
    MESA_SHADER_CACHE_MAX_SIZE = "4G";
  };

  # Proton-GE as a Steam compatibility tool (shows up in Steam dropdown)
  programs.steam.extraCompatPackages = with pkgs; [
    proton-ge-bin
  ];

  # --- Kernel params for gaming performance ---
  boot.kernelParams = [
    "split_lock_detect=off"                  # Prevent kernel penalizing split-lock games (DRG, etc.) — big FPS gain
    "mitigations=off"                        # Disable CPU spectre/meltdown mitigations — 5-15% FPS gain
  ];
  boot.kernel.sysctl = {
    "vm.max_map_count" = 2147483642;        # Required for CS2, Rust, some Proton titles
    "net.core.somaxconn" = 4096;            # Better multiplayer connection burst handling
    "fs.file-max" = 524288;                 # Raise FD limit for heavy games
  };
}
