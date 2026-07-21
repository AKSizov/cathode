{ inputs, pkgs, lib, ... }:
{
  # ============================================================================
  # Core System Configuration
  # ============================================================================
  # This module contains all core system settings including boot, networking,
  # security, services, and containerization.

  # Core system packages
  environment.systemPackages = with pkgs; [
    vim
    git
    htop
    glances
    inxi
    lz4
    pv
    podman-compose
    nixfmt-rfc-style
  ];

  # Enable unfree packages
  nixpkgs.config.allowUnfree = true;

  # Full firmware support for all hardware (Wi-Fi, GPUs, etc.)
  hardware.enableAllFirmware = true;

  # ============================================================================
  # Hardware Support
  # ============================================================================

  hardware.bluetooth.enable = true;
  hardware.graphics.enable = true;

  # ============================================================================
  # Boot & Kernel Configuration
  # ============================================================================

  boot = {
    # Supported filesystems
    supportedFilesystems = [ "ntfs" "btrfs" ];
    
    # Enable systemd in initrd for faster boot and hibernation
    initrd.systemd.enable = true;
    initrd.systemd.tpm2.enable = true;
    
    # Kernel parameters for performance and memory management
    kernelParams = [
      "zswap.enabled=1"
      "preempt=full"
      "mem_sleep_default=deep"
    ];
    
    # Kernel sysctl tuning
    kernel.sysctl = {
      # Memory Management
      "vm.swappiness" = 10;                    # Prefer RAM over swap
      "vm.vfs_cache_pressure" = 50;            # Retain inode/dentry cache

      # Networking - Modern TCP stack
      "net.core.default_qdisc" = "fq";         # Fair Queue for better latency
      "net.ipv4.tcp_congestion_control" = "bbr"; # BBR congestion control

      # Security Hardening
      "kernel.kptr_restrict" = 1;              # Hide kernel pointers
      "kernel.dmesg_restrict" = 1;             # Restrict dmesg to root
      "kernel.unprivileged_bpf_disabled" = 1;  # Disable unprivileged BPF
      "kernel.yama.ptrace_scope" = 1;          # Restrict ptrace to parent processes
      
      # Filesystem - Common desktop needs
      "fs.inotify.max_user_watches" = 524288;  # For IDEs, file watchers (VSCode, etc.)

      # System Debugging
      "kernel.sysrq" = 502;                    # Enable safe SysRq commands (reboot, sync, etc.)
    };
    
    # Bootloader configuration
    loader = {
      efi.canTouchEfiVariables = lib.mkDefault true;
      systemd-boot.enable = lib.mkDefault true;
      timeout = 1;
    };
  };

  # ============================================================================  
  # Nix Daemon Priority
  # ============================================================================
  # Nice the build daemon so it yields CPU and I/O to interactive use
  systemd.services.nix-daemon.serviceConfig = {
    Nice = lib.mkForce 10;                  # Lower CPU priority (0=normal, 19=lowest)
    IOSchedulingClass = lib.mkForce "idle";  # Only use disk I/O when nothing else needs it
  };

  # ============================================================================
  # Swap Strategy
  # ============================================================================
  # Three-layer approach for universal memory management:
  #
  # Layer 1: zramSwap (below) — Compressed swap in RAM, dynamically grows/shrinks
  #   with memory pressure. Up to 50% of physical RAM, lz4 compression.
  #   This is the primary "dynamic" swap layer — no disk I/O needed.
  #
  # Layer 2: zswap (kernel param above) — Compresses pages before writing to disk
  #   swapfile, reducing disk I/O when Layer 1 is exhausted.
  #
  # Layer 3: Disk swapfile (per-host) — Static overflow on disk for pathological
  #   cases. Only configured on hosts that need it (desktops with enough disk).
  #   Server/VPS hosts rely on zram alone.
  #
  # Result: Most swap happens in compressed RAM (fast), disk is only touched
  # under extreme memory pressure — similar to Windows' dynamic pagefile but
  # faster because zram compression ratios typically achieve 2-3x.

  zramSwap = {
    enable = true;
    algorithm = "lz4";
    memoryPercent = 50;
  };

  # ============================================================================
  # Networking
  # ============================================================================

  # NetworkManager for WiFi management (Noctalia panel compat)
  networking.networkmanager.enable = true;

  # ============================================================================
  # Nix Configuration
  # ============================================================================

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      # Enable flakes and new command-line interface
      experimental-features = "nix-command flakes";
      connect-timeout = 5; # Prevent hanging on unreachable substitutes
      max-jobs = "auto";   # Build derivations in parallel using all cores
      cores = 0;            # No per-build core limit (each build can use all cores)
      trusted-users = [ "user" ];
    };
    
    # Pin flake inputs in registry so `nix run nixpkgs#hello` uses system nixpkgs
    registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
    
    # Automatic garbage collection
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
    
    # Automatic store optimization
    optimise.automatic = true;
  };

  # ============================================================================
  # Security
  # ============================================================================

  # Disable password requirement for wheel group sudo
  security.sudo.wheelNeedsPassword = false;

  # ============================================================================
  # Services
  # ============================================================================

  # SSH server configuration
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # Laptop lid switch behavior
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
    PowerKey = "hibernate";
    PowerKeyLongPress = "hibernate";
  };
  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "60m";
    SuspendState = "mem";
  };

  # Device management and mounting
  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.hardware.bolt.enable = true;

  # Tailscale VPN
  services.tailscale.enable = true; # auth with sudo tailscale up --auth-key=KEY
  services.tailscale.package = pkgs.tailscale.overrideAttrs { doCheck = false; };
  services.tailscale.extraUpFlags = [ "--accept-routes" ];

  # ============================================================================
  # Virtualisation & Containers
  # ============================================================================

  # Container support
  virtualisation.containers.enable = true;
  
  # Podman configuration
  virtualisation.podman = {
    enable = true;
    dockerCompat = true; # Docker compatibility alias
    defaultNetwork.settings.dns_enabled = true; # Enable DNS for containers
  };

}
