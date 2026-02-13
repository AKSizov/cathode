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
  ];

  # Enable unfree packages
  nixpkgs.config.allowUnfree = true;

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
    
    # Use Zen kernel by default for better desktop performance
    kernelPackages = lib.mkDefault pkgs.linuxPackages_zen;
    
    # Kernel parameters for performance and memory management
    kernelParams = [
      "zswap.enabled=1"
      "preempt=full"
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
  # Swap Configuration
  # ============================================================================
  
  swapDevices = [{
    device = "/swapfile";
    size = 16 * 1024; # 16GB in MB
  }];
  
  # ZRAM swap for compression
  zramSwap = {
    enable = true;
    algorithm = "lz4";
    memoryPercent = 50;
  };

  # ============================================================================
  # Networking
  # ============================================================================

  # Wireless networking with iwd
  networking.wireless.iwd = {
    enable = true;
    settings.General.EnableNetworkConfiguration = true;
  };

  # ============================================================================
  # Nix Configuration
  # ============================================================================

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      # Enable flakes and new command-line interface
      experimental-features = "nix-command flakes";
    };
    
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
  services.logind = {
    lidSwitch = "suspend";
    lidSwitchDocked = "ignore";
  };

  # Device management and mounting
  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.hardware.bolt.enable = true;

  # Tailscale VPN
  services.tailscale.enable = true;
  services.tailscale.package = pkgs.tailscale.overrideAttrs { doCheck = false; };

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

  # ============================================================================
  # System Auto-Upgrade
  # ============================================================================

  system.autoUpgrade = {
    enable = true;
    flake = "github:AKSizov/cathode";
    flags = [
      "--update-input" "nixpkgs"
      "-L"
    ];
    dates = "02:00";
    randomizedDelaySec = "1h";
  };
}
