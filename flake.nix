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
    
    hyprpanel.url = "github:Jas-SinghFSU/HyprPanel";
  };

  outputs = { self, nixpkgs, ... } @ inputs: {
    nixosConfigurations = {
      mininix = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; outputs = self; };
        modules = [ ./hosts/mininix ];
      };

      m1n1x = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = { inherit inputs; outputs = self; };
        modules = [ ./hosts/m1n1x ];
      };

      closetcard = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; outputs = self; };
        modules = [ ./hosts/closetcard ];
      };

      snow-nix = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; outputs = self; };
        modules = [ ./hosts/snow-nix ];
      };
    };
  };
}
