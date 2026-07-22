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
  system.stateVersion = lib.mkDefault "26.05";

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
  services.throttled = {
    enable = true;
    extraConfig = ''
      [GENERAL]
      Enabled: True
      Sysfs_Power_Path: /sys/class/power_supply/AC*/online
      Autoreload: True

      [BATTERY]
      Update_Rate_s: 30
      PL1_Tdp_W: 25
      PL1_Duration_s: 28
      PL2_Tdp_W: 44
      PL2_Duration_s: 5
      Trip_Temp_C: 85
      cTDP: 0
      Disable_BDPROCHOT: True

      [AC]
      Update_Rate_s: 5
      PL1_Tdp_W: 40
      PL1_Duration_s: 28
      PL2_Tdp_W: 54
      PL2_Duration_s: 10
      Trip_Temp_C: 95
      cTDP: 0
      Disable_BDPROCHOT: True

      [UNDERVOLT.BATTERY]
      CORE: 0
      GPU: 0
      CACHE: 0
      UNCORE: 0
      ANALOGIO: 0

      [UNDERVOLT.AC]
      CORE: 0
      GPU: 0
      CACHE: 0
      UNCORE: 0
      ANALOGIO: 0
    '';
  };


  # Home Manager configuration
  home-manager.users.user = import ../modules/home-manager/desktop.nix;
}
