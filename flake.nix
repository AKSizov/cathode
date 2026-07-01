{
  description = "Cathode - A clean NixOS distribution";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell/3aab45a2f34fd47666b05892b95054952e788de1";
    };

    hardware.url = "github:NixOS/nixos-hardware/master";
    
    nixos-apple-silicon.url = "github:nix-community/nixos-apple-silicon/main";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
        wyse1 = mkHost "x86_64-linux" ./hosts/wyse1.nix;
      };
    };
}
