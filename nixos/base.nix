{
    inputs,
    pkgs,
    lib,
    ...
}:{

  environment.systemPackages = with pkgs; [
    hyprpolkitagent
    podman-compose
    firefox
    glances
    tpm2-tss
    inxi
    vim
    git
    lz4
    pv
  ];

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
    };
    gc = {
      automatic = true;  # Enable the automatic garbage collector
      dates = "daily";   # When to run the garbage collector
      options = "--delete-older-than 7d";    # Arguments to pass to nix-collect-garbage
    };
    optimise.automatic = true;
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  nixpkgs.config.allowUnfree = true;

  # This setups a SSH server. Very important if you're setting up a headless system.
  # Feel free to remove if you don't need it.
  services.openssh = {
    enable = true;
    settings = {
      # Opinionated: forbid root login through SSH.
      PermitRootLogin = "no";
      # Opinionated: use keys only.
      # Remove if you want to SSH using passwords
      PasswordAuthentication = false;
      #X11Forwarding = true;
    };
  };

  services.logind = {
    lidSwitch = "suspend";
    lidSwitchDocked = "ignore";
  };

  networking.wireless.iwd = {
    enable = true;
    settings.General.EnableNetworkConfiguration = true;
  };

  boot = {
    supportedFilesystems = [ "ntfs" ];
    initrd.systemd.enable = true; # This enables hibernation
    #plymouth.enable = true; # It's an option, if wanted
    kernelPackages = lib.mkDefault pkgs.linuxPackages_zen;
    kernelParams = [
      "zswap.enabled=1"
      "preempt=full"
    ];
    kernel.sysctl = {
      # Memory Management
      "vm.swappiness" = 10;                         # Favor RAM over swap
      "vm.dirty_background_ratio" = 10;             # Start background writeback at 10%
      "vm.dirty_ratio" = 40;                        # Max dirty page threshold before blocking
      "vm.dirty_expire_centisecs" = 2000;           # Dirty data age before eligible to flush (20s)
      "vm.dirty_writeback_centisecs" = 500;         # Periodic writeback interval (5s)
      "vm.vfs_cache_pressure" = 50;                 # Balance between inode cache and memory usage
      "vm.min_free_kbytes" = 65536;                 # Reserve memory for critical system needs

      # Memory Tuning (Advanced)
      "vm.page-cluster" = 0;                        # More granular swap I/O
      "vm.compaction_proactiveness" = 20;           # Reduce memory fragmentation
      "vm.zone_reclaim_mode" = 0;                   # Avoid reclaiming node-local memory (better NUMA perf)

      # Networking – Performance & Latency
      "net.core.default_qdisc" = "fq";              # Enables fair queuing (needed for BBR)
      "net.ipv4.tcp_congestion_control" = "bbr";    # Use BBR congestion control
      "net.core.netdev_max_backlog" = 5000;         # Larger NIC input queue
      "net.core.somaxconn" = 1024;                  # Max TCP listen backlog
      "net.ipv4.tcp_tw_reuse" = 1;                  # Reuse TIME_WAIT connections
      "net.ipv4.tcp_fin_timeout" = 15;              # Shorten FIN_WAIT2 timeout
      "net.ipv4.ip_local_port_range" = "10240 65535"; # Wider port range for outgoing connections

      # TCP Tuning
      "net.ipv4.tcp_fastopen" = 3;                  # TCP Fast Open (client + server)
      "net.ipv4.tcp_window_scaling" = 1;            # Enable TCP window scaling
      "net.ipv4.tcp_timestamps" = 1;                # Improve RTT estimates
      "net.ipv4.tcp_sack" = 1;                      # Enable selective ACKs
      "net.core.rmem_max" = 16777216;               # Max TCP read buffer
      "net.core.wmem_max" = 16777216;               # Max TCP write buffer
      "net.ipv4.tcp_rmem" = "4096 87380 16777216";  # TCP read buffer tuning
      "net.ipv4.tcp_wmem" = "4096 65536 16777216";  # TCP write buffer tuning

      # Security Hardening
      "kernel.kptr_restrict" = 1;                   # Hide kernel pointers
      "kernel.dmesg_restrict" = 1;                  # Restrict dmesg to root
      "kernel.unprivileged_bpf_disabled" = 1;       # Restrict BPF usage
      "kernel.yama.ptrace_scope" = 1;               # Restrict ptrace to parent processes
      "kernel.randomize_va_space" = 2;              # Full ASLR

      # Filesystem & I/O
      "fs.inotify.max_user_watches" = 1048576;      # Prevent inotify limit issues (e.g. IDEs)
      "fs.file-max" = 2097152;                      # Max system-wide open files
      "fs.nr_open" = 1048576;                       # Max open files per process
      "fs.aio-max-nr" = 1048576;                    # Max async I/O events system-wide

      # Hardware-specific
      "dev.raid.speed_limit_max" = 500000;         # Only if using software RAID

      # Debug
      "kernel.sysrq" = 502;
    };
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
      # Below doesn't work on arm systems
      # systemd-boot.memtest86.enable = true;
      # systemd-boot.netbootxyz.enable = true;
      timeout = 1;
    };
  };
  
  swapDevices = [ {
    device = "/swapfile";
    size = 16*1024; # Megabytes
  } ];
  
  zramSwap = {
    enable = true;
    algorithm = "lz4";
    # This refers to the uncompressed size, actual memory usage will be lower.
    memoryPercent = 50;
  };

  hardware.bluetooth.enable = true;

  hardware.graphics = {
    enable = true;
    # extraPackages = with pkgs; [
    #  intel-media-driver # For Broadwell (2014) or newer processors. LIBVA_DRIVER_NAME=iHD
    #  intel-vaapi-driver # For older processors. LIBVA_DRIVER_NAME=i965
    # ];
  };

  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.hardware.bolt.enable = true;
  services.tailscale.enable = true; # sudo tailscale up --auth-key=KEY
  services.tailscale.package = pkgs.tailscale.overrideAttrs { doCheck = false; };
  security.sudo.wheelNeedsPassword = false;
 
  programs.adb.enable = true;

  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  system.autoUpgrade = {
    rebootWindow = {
      lower = "03:00";
      upper = "05:00";
    };
    randomizedDelaySec = "1h";
    flake = inputs.self.outPath;
    dates = "3:00";
  };

  system.stateVersion = "24.11";
}
