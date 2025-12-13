{
  description = "";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    stylix.url = "github:nix-community/stylix/release-25.05";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    
    # NixOS Hardware
    hardware.url = "github:NixOS/nixos-hardware/master";

    # Apple silicon support (m-series chips)
    nixos-apple-silicon.url = "github:nix-community/nixos-apple-silicon/release-25.05";

    # Ricing
    hyprpanel.url = "github:Jas-SinghFSU/HyprPanel";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    hardware,
    nixos-apple-silicon,
    stylix,
    ...
  } @ inputs: let
    inherit (self) outputs;
  in {
    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      mininix = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs outputs;};
        modules = [
          # Module Imports
          stylix.nixosModules.stylix
          home-manager.nixosModules.home-manager
          # If you want to use modules from nixos-hardware:
          #hardware.nixosModules.common-cpu-amd
          hardware.nixosModules.common-pc-ssd
          #hardware.nixosModules.common-gpu-nvidia
          #hardware.nixosModules.common-gpu-amd
          hardware.nixosModules.common-cpu-intel

          ./nixos/base.nix # Base OS configuration
          #./nixos/nvidia.nix # Machines with nvidia cards
          ./nixos/gui.nix # Disable this gui module if you're running headless (server)

          ./hardware-configs/hw-mininix.nix # (nixos-generate-config) hardware configuration

          {
            networking.hostName = "mininix";
            networking.nameservers = [ "1.1.1.1" "9.9.9.9" ];
            time.timeZone = "America/New_York";

            users.users = {
              user = {
                initialPassword = "correcthorsebatterystaple";
                isNormalUser = true;
                linger = true; # Starts user services on boot
                openssh.authorizedKeys.keys = [
                  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILp3QWpsKLZtI38se2R5JatwUUJ4g6i95cTvYtYTo5Wb"
                ];
                extraGroups = ["wheel" "video" "audio" "networkmanager"];
              };
            };
            home-manager.users.user = import ./home-manager/gui.nix; # gui.nix for DE, base.nix for headless
            home-manager.extraSpecialArgs = { inherit inputs outputs; };

            #system.autoUpgrade.enable = true;
            #system.autoUpgrade.allowReboot = true;
          }
        ];
      };
      m1n1x = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = {inherit inputs outputs;};
        modules = [
          # Module Imports
          stylix.nixosModules.stylix
          home-manager.nixosModules.home-manager
          nixos-apple-silicon.nixosModules.apple-silicon-support

          ./nixos/base.nix # Base OS configuration
          ./nixos/gui.nix # Disable this gui module if you're running headless (server)
          
          ./hardware-configs/hw-m1n1x.nix # (nixos-generate-config) hardware configuration
          {
            #hardware.asahi.peripheralFirmwareDirectory = ./asahi-firmware;
            hardware.asahi.useExperimentalGPUDriver = true;
            boot.kernelParams = [ "apple_dcp.show_notch=1"];
            boot.extraModprobeConfig = ''
              options hid_apple fnmode=2 swap_fn_leftctrl=1
            '';

            boot.loader.efi.canTouchEfiVariables = false;
            networking.hostName = "m1n1x";

            networking.nameservers = [ "1.1.1.1" "9.9.9.9" ];
            time.timeZone = "America/New_York";

            users.users = {
              user = {
                initialPassword = "correcthorsebatterystaple";
                isNormalUser = true;
                linger = true; # Starts user services on boot
                openssh.authorizedKeys.keys = [
                  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILp3QWpsKLZtI38se2R5JatwUUJ4g6i95cTvYtYTo5Wb"
                ];
                extraGroups = ["wheel" "video" "audio" "networkmanager"];
              };
            };
            home-manager.users.user = import ./home-manager/gui.nix; # gui.nix for DE, base.nix for headless
            home-manager.extraSpecialArgs = { inherit inputs outputs; };

            #system.autoUpgrade.enable = true;
            #system.autoUpgrade.allowReboot = true;
          }
        ];
      };
      closetcard = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs outputs;};
        modules = [
          # Module Imports
          stylix.nixosModules.stylix
          home-manager.nixosModules.home-manager
          # If you want to use modules from nixos-hardware:
          #hardware.nixosModules.common-cpu-amd
          hardware.nixosModules.common-pc-ssd
          hardware.nixosModules.common-gpu-nvidia
          #hardware.nixosModules.common-gpu-amd
          hardware.nixosModules.common-cpu-intel

          ./nixos/base.nix # Base OS configuration
          ./nixos/nvidia.nix # Machines with nvidia cards
          #./nixos/gui.nix # Disable this gui module if you're running headless (server)

          ./hardware-configs/hw-closetcard.nix # (nixos-generate-config) hardware configuration

          {
            networking.hostName = "closetcard";
            networking.nameservers = [ "1.1.1.1" "9.9.9.9" ];
            time.timeZone = "America/New_York";
            networking.useDHCP = false;
            #networking.interfaces.enp0s31f6.ipv4.addresses = [ {
            networking.interfaces.eno1.ipv4.addresses = [ {
              address = "192.168.1.101";
              prefixLength = 24;
            } ];
            networking.defaultGateway = "192.168.1.1";

            #boot.extraModprobeConfig = ''
            #  options nvidia NVreg_RegistryDwords="RMForcePstate=2"
            #'';

            systemd.targets.sleep.enable = false;
            systemd.targets.suspend.enable = false;
            systemd.targets.hibernate.enable = false;
            systemd.targets.hybrid-sleep.enable = false;

            users.users = {
              user = {
                initialPassword = "correcthorsebatterystaple";
                isNormalUser = true;
                linger = true; # Starts user services on boot
                openssh.authorizedKeys.keys = [
                  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILp3QWpsKLZtI38se2R5JatwUUJ4g6i95cTvYtYTo5Wb"
                ];
                extraGroups = ["wheel" "video" "audio" "networkmanager"];
              };
            };
            home-manager.users.user = import ./home-manager/base.nix; # gui.nix for DE, base.nix for headless
            home-manager.extraSpecialArgs = { inherit inputs outputs; };

            system.autoUpgrade.enable = true;
            system.autoUpgrade.allowReboot = true;
          }
        ];
      };
      snow-nix = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs outputs;};
        modules = [
          # Module Imports
          stylix.nixosModules.stylix
          home-manager.nixosModules.home-manager
          # If you want to use modules from nixos-hardware:
          #hardware.nixosModules.common-cpu-amd
          hardware.nixosModules.common-pc-ssd
          hardware.nixosModules.common-gpu-nvidia
          #hardware.nixosModules.common-gpu-amd
          hardware.nixosModules.common-cpu-intel

          ./nixos/base.nix # Base OS configuration
          ./nixos/nvidia.nix # Machines with nvidia cards
          ./nixos/gui.nix # Disable this gui module if you're running headless (server)

          ./hardware-configs/hw-snow-nix.nix # (nixos-generate-config) hardware configuration

          {
            networking.hostName = "snow-nix";
            networking.nameservers = [ "1.1.1.1" "9.9.9.9" ];
            time.timeZone = "America/New_York";
            users.users = {
              user = {
                initialPassword = "correcthorsebatterystaple";
                isNormalUser = true;
                linger = true; # Starts user services on boot
                openssh.authorizedKeys.keys = [
                  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILp3QWpsKLZtI38se2R5JatwUUJ4g6i95cTvYtYTo5Wb"
                ];
                extraGroups = ["wheel" "video" "audio" "networkmanager"];
              };
            };
            home-manager.users.user = import ./home-manager/gui.nix; # gui.nix for DE, base.nix for headless
            home-manager.extraSpecialArgs = { inherit inputs outputs; };
          }
        ];
      };
    };
  };
}
