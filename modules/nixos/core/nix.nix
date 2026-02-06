{ inputs, lib, ... }:
{
  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      # Enable flakes and new command-line interface
      experimental-features = "nix-command flakes";
    };
    
    # Automatic garbage collection
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
    
    # Automatic store optimization
    optimise.automatic = true;
  };

  # System auto-upgrade configuration
  system.autoUpgrade = {
    rebootWindow = {
      lower = "03:00";
      upper = "05:00";
    };
    randomizedDelaySec = "1h";
    flake = inputs.self.outPath;
    dates = "3:00";
  };
}
