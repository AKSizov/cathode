{ pkgs, lib, ... }:
let
  # --- OpenNOW (open-source GeForce NOW client) ---
  # Upstream's recommended Linux package is the Type-2 AppImage, wrapped in an
  # FHS env so its bundled Qt 6.8+/SDL3/Rust streamer resolve on NixOS.
  # Hardware decode is VA-API (upstream: docs/linux-video-backends.md). The
  # AppImage's AppRun hook picks libva via `ldconfig -p`: the FHS env generates
  # the ld cache at startup, so including nixpkgs libva here makes the hook use
  # it (ABI-matched to nixpkgs intel-media-driver) instead of the bundled
  # Ubuntu libva 2.20, which cannot load a newer-ABI VA driver.
  # intel-media-driver lands at /usr/lib/dri inside the env — nixpkgs libva's
  # default driverdir. Version bumps: update version + hash (upstream release
  # asset; hash verified against upstream's signed .manifest.json).
  opennow = pkgs.appimageTools.wrapType2 {
    pname = "opennow";
    version = "1.0.3";
    src = pkgs.fetchurl {
      url = "https://github.com/OpenCloudGaming/OpenNOW/releases/download/v1.0.3/OpenNOW-Qt-1.0.3-Linux-x64.AppImage";
      hash = "sha256-xG1Wzyk89VMhsA4Pc32e9nmbceq6wGBRhgsiK2j5EDo=";
    };
    extraPkgs = p: [
      p.libva
      p.intel-media-driver
    ];
    meta = {
      description = "Open-source GeForce NOW client";
      homepage = "https://opennow.zortos.me/";
      license = lib.licenses.mit;
      platforms = [ "x86_64-linux" ];
    };
  };
in
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
    opennow                                  # GeForce NOW client (wrapped AppImage — see let block above)
  ];

  services.flatpak.enable = true; 

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
