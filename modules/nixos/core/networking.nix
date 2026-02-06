{ ... }:
{
  # Wireless networking with iwd
  networking.wireless.iwd = {
    enable = true;
    settings.General.EnableNetworkConfiguration = true;
  };
}
