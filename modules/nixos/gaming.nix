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
  # prismlauncher is just a package, not a NixOS program module

  # --- System packages ---
  environment.systemPackages = with pkgs; [
    prismlauncher                          # MultiMC-fork launcher with mod management
    mangohud                                # FPS/frame timing overlay (run games with `mangohud %command%`)
    proton-ge-custom                        # GloriousEggroll Proton — extra codecs and patches
  ];

  # Tell Steam where to find Proton-GE
  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/etc/steam-compat-tools";
  };

  # Symlink Proton-GE into Steam's compatibility tools search path
  environment.etc."steam-compat-tools/proton-ge-custom" = {
    source = "${pkgs.proton-ge-custom}/share/steam-proton-ge-custom";
  };

  # --- Kernel sysctl tuning for gaming ---
  boot.kernel.sysctl = {
    "vm.max_map_count" = 2147483642;        # Required for CS2, Rust, some Proton titles
    "net.core.somaxconn" = 4096;            # Better multiplayer connection burst handling
    "fs.file-max" = 524288;                 # Raise FD limit for heavy games
  };
}
