{ inputs, lib, ... }:
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
  # --ignore-cpuid-check: ThinkPad not in upstream CPU ID table
  # Custom config raises trip point to 105°C (CPU package temp) — prevents
  # thermald's default 48°C mainboard-sensor threshold from throttling at idle
  services.thermald = {
    enable = true;
    ignoreCpuidCheck = true;
    configFile = builtins.toFile "thermal-conf.xml" ''
      <?xml version="1.0"?>
      <ThermalConfiguration>
        <Platform>
          <Name>ThinkPad T14 Gen3</Name>
          <ProductName>*</ProductName>
          <Preference>QUIET</Preference>
          <ThermalSensors>
            <ThermalSensor>
              <Type>x86_pkg_temp</Type>
              <AsyncCapable>1</AsyncCapable>
            </ThermalSensor>
          </ThermalSensors>
          <ThermalZones>
            <ThermalZone>
              <Type>cpu</Type>
              <TripPoints>
                <TripPoint>
                  <SensorType>x86_pkg_temp</SensorType>
                  <Temperature>105000</Temperature>
                  <type>passive</type>
                  <ControlType>SEQUENTIAL</ControlType>
                  <CoolingDevice>
                    <index>1</index>
                    <type>rapl_controller_mmio</type>
                    <influence>100</influence>
                    <SamplingPeriod>10</SamplingPeriod>
                  </CoolingDevice>
                </TripPoint>
              </TripPoints>
            </ThermalZone>
          </ThermalZones>
        </Platform>
      </ThermalConfiguration>
    '';
  };

  # Home Manager configuration
  home-manager.users.user = import ../modules/home-manager/desktop.nix;
}
