{
  description = "Cathode - A clean NixOS distribution";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    stylix = {
      url = "github:nix-community/stylix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    hardware.url = "github:NixOS/nixos-hardware/master";
    
    nixos-apple-silicon.url = "github:nix-community/nixos-apple-silicon/main";

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake/beta";
      inputs = {
        # IMPORTANT: To ensure compatibility with the latest Firefox version, use nixpkgs-unstable.
        nixpkgs.follows = "nixpkgs";
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
      };
    };
}
