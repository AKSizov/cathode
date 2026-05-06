# Cachix configuration for cathode
#
# After creating the cachix cache (see .github/workflows/ci.yml for setup),
# add the public key and enable this module on all cathode hosts.
#
# Usage: import this file in your host config, then set:
#   cathode.cachix.enable = true;
#   cathode.cachix.publicKey = "cathode.cachix.org-1:<KEY_FROM_CACHIX>";

{ config, lib, ... }:

let
  cfg = config.cathode.cachix;
in
{
  options.cathode.cachix = {
    enable = lib.mkEnableOption "Cathode Cachix binary cache";

    publicKey = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Public key for the cathode cachix cache";
      example = "cathode.cachix.org-1:abcdef1234567890...";
    };
  };

  config = lib.mkIf cfg.enable {
    nix.settings = {
      substituters = [ "https://cathode.cachix.org" ];
      trusted-public-keys = [ cfg.publicKey ];
    };
  };
}
