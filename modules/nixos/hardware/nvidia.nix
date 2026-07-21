{ config, ... }:
{
  # NVIDIA driver configuration
  services.xserver.videoDrivers = [ "nvidia" ];
  
  hardware.nvidia = {
    # Required for proper operation
    modesetting.enable = true;

    # Power management (can help with sleep/suspend issues)
    powerManagement.enable = true;
    powerManagement.finegrained = false;

    # Use proprietary driver (not nouveau)
    open = false;

    # Enable settings menu
    nvidiaSettings = true;

    # Enable persistence daemon
    nvidiaPersistenced = true;
    
    # Disable GSP firmware
    gsp.enable = false;

    # Use stable driver version
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # PRIME configuration (disabled by default)
    prime = {
      sync.enable = false;
      reverseSync.enable = false;
      offload.enable = false;
    };
  };

  # Enable NVIDIA container toolkit
  hardware.nvidia-container-toolkit.enable = true;
}
