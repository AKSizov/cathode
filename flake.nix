{
  description = "Cathode - A clean NixOS distribution";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };


    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
    };

    hardware.url = "github:NixOS/nixos-hardware/master";
    
    nixos-apple-silicon.url = "github:nix-community/nixos-apple-silicon/main";

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake/beta";
      inputs = {
        # zen-browser needs nixpkgs-unstable for latest Firefox compatibility
        # Do NOT follow our nixpkgs (25.11) — it will cause version mismatch
        home-manager.follows = "home-manager";
      };
    };
  };

  outputs = { self, nixpkgs, ... } @ inputs:
    let
      # Helper function to reduce boilerplate
      mkHost = system: hostPath: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; outputs = self; };
        modules = [ hostPath ];
      };
    in
    {
      nixosConfigurations = {
        mininix = mkHost "x86_64-linux" ./hosts/mininix.nix;
        m1n1x = mkHost "aarch64-linux" ./hosts/m1n1x.nix;
        closetcard = mkHost "x86_64-linux" ./hosts/closetcard.nix;
        grassblock = mkHost "aarch64-linux" ./hosts/grassblock.nix;
        foundry = mkHost "x86_64-linux" ./hosts/foundry.nix;
      };
    };
}
