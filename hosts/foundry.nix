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

  # Intel thermal monitoring and passive cooling
  services.thermald.enable = true;
  environment.etc."thermald/thermal-conf.xml".source = ../thermal-conf.xml;
  systemd.services.thermald.serviceConfig.ExecStart =
    lib.mkForce "${pkgs.thermald}/sbin/thermald --ignore-cpuid-check --config-file /etc/thermald/thermal-conf.xml";

  # Home Manager configuration
  home-manager.users.user = import ../modules/home-manager/desktop.nix;
}
