{
  description = "Cathode - A clean NixOS distribution";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell/3aab45a2f34fd47666b05892b95054952e788de1";
    };

    hardware = {
      url = "github:NixOS/nixos-hardware/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    nixos-apple-silicon = {
      url = "github:nix-community/nixos-apple-silicon/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake/beta";
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
