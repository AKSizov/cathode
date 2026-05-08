# Default host configuration - common settings for all hosts
{ inputs, outputs, lib, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.stylix.nixosModules.stylix
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs outputs; };
  };

  # Common settings across all hosts
  networking.nameservers = [ "1.1.1.1" "9.9.9.9" ];
  time.timeZone = lib.mkDefault "America/New_York";

  # State version
  system.stateVersion = "24.11";
}
