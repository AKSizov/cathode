{ pkgs, lib, ... }:
{
  # ============================================================================
  # Gaming Module
  # ============================================================================
  # Core gaming support, controller drivers, system optimizations, and tools

  # --- Steam ---
  # gamemode lib must be in Steam's FHS sandbox or games can't request it
  # https://github.com/NixOS/nixpkgs/issues/389142
  programs.steam = {
    enable = true;
    package = pkgs.steam.override { extraPkgs = p: [ p.gamemode ]; };
    remotePlay.openFirewall = true;          # Steam Remote Play
    localNetworkGameTransfers.openFirewall = true; # LAN game transfers
    protontricks.enable = true;              # Winetricks wrapper for Proton prefixes
  };

  # --- 32-bit graphics support ---
  # Required for 32-bit and Proton games — without this, most games won't launch
  hardware.graphics.enable32Bit = true;

  # --- Controller support ---
  hardware.xpadneo.enable = true;           # Xbox Bluetooth controller (better than in-kernel xpad)

  # --- GameMode ---
  # Feral's on-demand system optimizer: CPU governor boost, I/O priority,
  # screensaver inhibition, etc. Games request it via `gamemoded` or `gameMode` hint
  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice = 10;                        # Give game processes higher priority
        ioprio = 0;                         # Best-effort I/O scheduling
        desiredgov = "schedutil";           # Dynamic governor — iGPU needs TDP headroom, performance starves it
        igpu_desiredgov = "schedutil";      # Same for iGPU governor
      };
      gpu = {
        apply_gpu_optimisations = 0;        # No dGPU to tune (integrated Intel)
      };
    };
  };

  # Add user to gamemode group so they can request it
  users.users.user.extraGroups = [ "gamemode" ];

  # --- Minecraft ---
  # Provide Java runtimes so Modrinth doesn't download its own (broken on NixOS)
  environment.systemPackages = with pkgs; [
    modrinth-app                              # Minecraft launcher — polished UI, built-in modpack browsing
    jdk8                                     # Minecraft <=1.16.5
    jdk17                                    # Minecraft 1.17–1.20.4
    jdk21                                    # Minecraft 1.20.5+
    mangohud                                 # FPS/frame timing overlay (run games with `mangohud %command%`)
    gamescope                                # Micro-compositor for lag-free gaming (use: gamescope --gamemode -- %command%)
  ];

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
