{ pkgs, lib, ... }:
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

  # --- GameMode ---
  # Feral's on-demand system optimizer: CPU governor boost, I/O priority,
  # screensaver inhibition, etc. Games request it via `gamemoded` or `gameMode` hint
  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice = 10;                        # Give game processes higher priority
        ioprio = 0;                         # Best-effort I/O scheduling
      };
      gpu = {
        apply_gpu_optimisations = 0;        # No dGPU to tune (integrated Intel)
      };
    };
  };

  # --- Minecraft ---
  # Provide Java runtimes so Modrinth doesn't download its own (broken on NixOS)
  environment.systemPackages = with pkgs; [
    modrinth-app                              # Minecraft launcher — polished UI, built-in modpack browsing
    jre8                                     # Minecraft <=1.16.5
    jre17                                    # Minecraft 1.17–1.20.4
    jre21                                    # Minecraft 1.20.5+
    mangohud                                 # FPS/frame timing overlay (run games with `mangohud %command%`)
  ];

  # Proton-GE as a Steam compatibility tool (shows up in Steam dropdown)
  programs.steam.extraCompatPackages = with pkgs; [
    proton-ge-bin
  ];

  # --- Kernel sysctl tuning for gaming ---
  boot.kernel.sysctl = {
    "vm.max_map_count" = 2147483642;        # Required for CS2, Rust, some Proton titles
    "net.core.somaxconn" = 4096;            # Better multiplayer connection burst handling
    "fs.file-max" = 524288;                 # Raise FD limit for heavy games
  };
}
