{ pkgs, ... }:
{
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
}
