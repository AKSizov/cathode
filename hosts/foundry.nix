{ inputs, lib, pkgs, ... }:
{
  imports = [
    ./default.nix
    ../modules/nixos/core.nix
    ../modules/nixos/desktop
    ../modules/nixos/gaming.nix
    ../modules/nixos/users.nix
    ../hardware-configs/hw-foundry.nix
    inputs.hardware.nixosModules.common-pc-laptop
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  networking.hostName = "foundry";

  # Use local RTC for Windows dual-boot compatibility
  # Windows expects hardware clock in local time; NixOS defaults to UTC
  time.hardwareClockInLocalTime = true;

  # Swap configuration (16GB swapfile)
  swapDevices = [{ device = "/swapfile"; size = 16 * 1024; }];

  # Secure boot
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };


  # ThinkPad fan control (uses thinkfan's built-in default fan curve)
  services.thinkfan.enable = true;

  # Lenovo ThinkPad throttling control (replaces thermald)
  # throttled (lenovo-throttling-fix) provides per-power-state PL1/PL2 limits,
  # undervolting, and trip temp overrides via intel MSR registers
  services.throttled.enable = true;
  environment.etc."throttled/config.ini".text = ''
    [GENERAL]
    Enabled: True
    Sysfs_Power_Path: /sys/class/power_supply/AC*/online
    Autoreload: True

    [BATTERY]
    Update_Rate_s: 30
    PL1_Tdp_W: 30
    PL1_Duration_s: 28
    PL2_Tdp_W: 44
    PL2_Duration_S: 5
    Trip_Temp_C: 85
    cTDP: 0
    Disable_BDPROCHOT: True

    [AC]
    Update_Rate_s: 5
    PL1_Tdp_W: 40
    PL1_Duration_s: 28
    PL2_Tdp_W: 54
    PL2_Duration_S: 10
    Trip_Temp_C: 95
    cTDP: 0
    Disable_BDPROCHOT: True

    [UNDERVOLT.BATTERY]
    CORE: -80
    GPU: -60
    CACHE: -80
    UNCORE: -60
    ANALOGIO: 0

    [UNDERVOLT.AC]
    CORE: -80
    GPU: -60
    CACHE: -80
    UNCORE: -60
    ANALOGIO: 0

    # Uncomment only if you still hit hard power limits after the above changes
    # [ICCMAX.AC]
    # CORE: 120
    # GPU: 80
    # CACHE: 120
  '';

  # Home Manager configuration
  home-manager.users.user = import ../modules/home-manager/desktop.nix;
}
