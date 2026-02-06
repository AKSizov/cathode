# Cathode

A clean, modular NixOS distribution with a focus on organization and maintainability.

## Structure

```
cathode/
├── flake.nix                 # Main flake configuration
├── hosts/                    # Host-specific configurations
│   ├── default.nix          # Shared host settings
│   ├── mininix/             # Desktop workstation (Intel/x86_64)
│   ├── m1n1x/               # Apple Silicon laptop (ARM64)
│   ├── closetcard/          # Headless server (NVIDIA GPU)
│   └── snow-nix/            # Desktop workstation (NVIDIA GPU)
├── modules/
│   ├── nixos/
│   │   ├── core.nix         # Base system (boot, networking, nix, services, containers)
│   │   ├── users.nix        # Default user configuration
│   │   ├── desktop/         # Desktop environment modules
│   │   │   ├── default.nix  # Desktop packages and services
│   │   │   ├── audio.nix    # PipeWire configuration
│   │   │   ├── hyprland.nix # Window manager
│   │   │   └── stylix.nix   # System theming
│   │   └── hardware/
│   │       └── nvidia.nix   # NVIDIA GPU support
│   └── home-manager/
│       ├── base.nix         # Core user environment (CLI tools, git, etc.)
│       └── desktop.nix      # Desktop user apps (GUI apps, Hyprland, themes)
├── hardware-configs/        # Hardware-specific configs (nixos-generate-config)
└── dotfiles/               # Traditional dotfiles integrated via Home Manager
```

## Features

- **Modular Design**: Configurations are split into logical, reusable modules
- **Multiple Profiles**: Desktop and headless server configurations
- **Performance Tuned**: Optimized kernel parameters and boot configuration
- **Modern Desktop**: Hyprland wayland compositor with Stylix theming
- **Container Support**: Podman with Docker compatibility
- **Security Hardened**: SSH key-only auth, kernel hardening, passwordless sudo for wheel
- **Auto-Updates**: Configurable automatic system upgrades

## Quick Start

### Building a Host

```bash
# Build and activate configuration
sudo nixos-rebuild switch --flake .#hostname

# Available hosts: mininix, m1n1x, closetcard, snow-nix
```

### Adding a New Host

1. Generate hardware configuration:
   ```bash
   nixos-generate-config --show-hardware-config > hardware-configs/hw-newhostname.nix
   ```

2. Create host configuration:
   ```bash
   mkdir hosts/newhostname
   ```

3. Add `hosts/newhostname/default.nix`:
   ```nix
   { inputs, ... }:
   {
     imports = [
       ../default.nix
       ../../modules/nixos/core.nix
       ../../modules/nixos/users.nix
       ../../modules/nixos/desktop  # Or omit for headless
       ../../hardware-configs/hw-newhostname.nix
     ];

     networking.hostName = "newhostname";

     # Home Manager configuration
     home-manager.users.user = import ../../modules/home-manager/desktop.nix;
     # For headless: import ../../modules/home-manager/base.nix;
   }
   ```

4. Add to `flake.nix` nixosConfigurations:
   ```nix
   newhostname = mkHost "x86_64-linux" ./hosts/newhostname;
   ```

## Customization

### Desktop vs Headless

- **Desktop**: Import `modules/nixos/desktop` and set home-manager to `../../modules/home-manager/desktop.nix`
- **Headless**: Skip desktop module and set home-manager to `../../modules/home-manager/base.nix`

### NVIDIA GPUs

Import the NVIDIA module in your host configuration:
```nix
../../modules/nixos/hardware/nvidia.nix
```

### Adding Packages

- **System-wide**: Add to `modules/nixos/core.nix` or `modules/nixos/desktop/default.nix`
- **User-specific**: Add to `modules/home-manager/base.nix` (CLI) or `modules/home-manager/desktop.nix` (GUI)

### Customizing User Settings

Default user configuration is in `modules/nixos/users.nix`. Override specific settings in your host config:
```nix
users.users.user.openssh.authorizedKeys.keys = [ "your-ssh-key" ];
```

## Philosophy

Cathode follows these principles:

1. **Separation of Concerns**: System, desktop, and user configs are separate
2. **Host-Specific Only at the Top**: Hosts import shared modules and override minimally
3. **No Boilerplate**: Common settings live in shared modules, not repeated per-host
4. **Clear Hierarchy**: Easy to find where any setting is configured
5. **Dotfiles Integration**: Traditional configs in `dotfiles/` sourced where needed

## License

See LICENSE file.
