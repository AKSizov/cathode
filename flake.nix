{
  description = "Cathode - A clean NixOS distribution";

  nixConfig = {
    extra-substituters = [ "https://noctalia.cachix.org" ];
    extra-trusted-public-keys = [ "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4=" ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Noctalia v5 — desktop shell (bar, notifications, lock, OSD, launcher, clipboard)
    # Pinned to main branch (beta). Pin a specific rev when stable.
    noctalia = {
      url = "github:noctalia-dev/noctalia";
      # Don't follow nixpkgs — keeps Cachix binary cache working
    };

    # Noctalia Greeter — graphical login screen that matches Noctalia theme
    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
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
      inputs = {
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
        grassblock = mkHost "aarch64-linux" ./hosts/grassblock.nix;
        foundry = mkHost "x86_64-linux" ./hosts/foundry.nix;
        wyse1 = mkHost "x86_64-linux" ./hosts/wyse1.nix;
      };
    };
}
