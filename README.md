# Cathode

A modular NixOS flake with a Hyprland + Noctalia desktop.

## Structure

- **`hosts/`** — Per-machine configs. Each host imports shared modules and overrides minimally.
- **`modules/nixos/`** — System-level modules (core, desktop, hardware).
- **`modules/home-manager/`** — User-level modules (`base.nix` for CLI, `desktop.nix` for GUI).
- **`hardware-configs/`** — Generated hardware configs (`nixos-generate-config`).

## Profiles

- **Desktop** — Hyprland, Noctalia shell, GUI apps. Import `modules/nixos/desktop` and `modules/home-manager/desktop.nix`.
- **Headless** — CLI tools only. Skip desktop module, use `modules/home-manager/base.nix`.

## Adding a Host

1. Generate hardware config into `hardware-configs/`.
2. Create a directory under `hosts/` with a `default.nix` that imports the relevant modules.
3. Add the host to `flake.nix` nixosConfigurations.

## Philosophy

Shared modules do the heavy lifting. Hosts are thin — import what you need, override only what's different. No repeated config, no stale boilerplate.
