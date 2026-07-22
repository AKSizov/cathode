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

  # --- modrinth-app fix (nixpkgs#541756, PR #542808) ---
  # symlinkJoin skips fixup phases; wrapGAppsHook broke on 0.15.7+.
  # Rebuild wrapper with direct wrapGApp call. Drop this when upstream merges.
  nixpkgs.overlays = [
    (final: prev: {
      modrinth-app = final.symlinkJoin {
        name = "modrinth-app-${final.modrinth-app-unwrapped.version}";
        paths = [ final.modrinth-app-unwrapped ];
        nativeBuildInputs = [ final.glib final.wrapGAppsHook3 ];
        buildInputs = [ final.glib-networking final.gsettings-desktop-schemas ];
        postBuild =
          let
            runtimeDeps = final.lib.makeLibraryPath [
              final.addDriverRunpath.driverLink
              final.libGL final.libx11 final.libxcursor final.libxext final.libxrandr final.libxxf86vm
              (final.lib.getLib final.stdenv.cc.cc)
              final.flite
              final.alsa-lib final.libjack2 final.libpulseaudio final.pipewire
              final.udev
            ];
          in
          ''
            gappsWrapperArgs+=(
              --prefix PATH : ${final.lib.makeSearchPath "bin/java" [ final.jdk8 final.jdk17 final.jdk21 final.jdk25 ]}
              --prefix PATH : ${final.lib.makeBinPath [ final.xrandr ]}
              --set LD_LIBRARY_PATH ${runtimeDeps}
            )
            wrapGApp "$out/bin/ModrinthApp"
          '';
        meta = final.modrinth-app-unwrapped.meta;
      };
    })
  ];


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
