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
    supportedFilesystems = [ "ntfs" ];
    
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
      "vm.swappiness" = 10;
      "vm.dirty_background_ratio" = 10;
      "vm.dirty_ratio" = 40;
      "vm.dirty_expire_centisecs" = 2000;
      "vm.dirty_writeback_centisecs" = 500;
      "vm.vfs_cache_pressure" = 50;
      "vm.min_free_kbytes" = 65536;
      "vm.page-cluster" = 0;
      "vm.compaction_proactiveness" = 20;
      "vm.zone_reclaim_mode" = 0;

      # Networking – Performance & Latency
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.core.netdev_max_backlog" = 5000;
      "net.core.somaxconn" = 1024;
      "net.ipv4.tcp_tw_reuse" = 1;
      "net.ipv4.tcp_fin_timeout" = 15;
      "net.ipv4.ip_local_port_range" = "10240 65535";

      # TCP Tuning
      "net.ipv4.tcp_fastopen" = 3;
      "net.ipv4.tcp_window_scaling" = 1;
      "net.ipv4.tcp_timestamps" = 1;
      "net.ipv4.tcp_sack" = 1;
      "net.core.rmem_max" = 16777216;
      "net.core.wmem_max" = 16777216;
      "net.ipv4.tcp_rmem" = "4096 87380 16777216";
      "net.ipv4.tcp_wmem" = "4096 65536 16777216";

      # Security Hardening
      "kernel.kptr_restrict" = 1;
      "kernel.dmesg_restrict" = 1;
      "kernel.unprivileged_bpf_disabled" = 1;
      "kernel.yama.ptrace_scope" = 1;
      "kernel.randomize_va_space" = 2;

      # Filesystem & I/O
      "fs.inotify.max_user_watches" = 1048576;
      "fs.file-max" = 2097152;
      "fs.nr_open" = 1048576;
      "fs.aio-max-nr" = 1048576;

      # Debug
      "kernel.sysrq" = 502;
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

  # Android debugging
  programs.adb.enable = true;

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
    rebootWindow = {
      lower = "03:00";
      upper = "05:00";
    };
    randomizedDelaySec = "1h";
    flake = inputs.self.outPath;
    dates = "3:00";
  };
}
