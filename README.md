# Dotfiles

This repository contains personal configuration files for multiple machines.

## Structure

- `windows/` - dotfiles and configuration for Windows machines
- `nixos/` - dotfiles and configuration for NixOS machines

## Windows

Windows dotfiles are managed with [chezmoi](https://www.chezmoi.io/).

To use the Windows configuration:

```powershell
chezmoi init https://github.com/markdlp/dotfiles.git
chezmoi apply
```

Replace `markdlp` with your GitHub username or repository source.

## NixOS & Dendritic Pattern

The `nix/` folder contains declarative system configurations for all Nix machines organized using the **Dendritic Pattern** with [flake-parts](https://github.com/hercules-ci/flake-parts) and [import-tree](https://github.com/denful/import-tree).

### Repository Layout

- `nix/flake.nix`: Minimal entry point importing dendritic aspects and hosts.
- `nix/aspects/`: Self-contained, auto-discovered feature modules (`core/`, `desktop/`, `hardware/`, `virtualisation/`, `dev/`, `wsl/`).
- `nix/hosts/`: Machine definitions and hardware specifications:
  - `body`: Desktop workstation (`x86_64-linux`, GNOME, NVIDIA, KVM/Whonix)
  - `waist`: Headless Raspberry Pi 4 (`aarch64-linux`, unstable channel, Docker)
  - `wsl`: Native NixOS on WSL instance (`x86_64-linux`, unstable channel)

### Deployment & Rebuilding

From inside the `nix/` directory (or pointing to your dotfiles repo):

```bash
# On Body (Desktop)
sudo nixos-rebuild switch --flake ~/dotfiles/nix#body

# On Waist (Raspberry Pi 4)
sudo nixos-rebuild switch --flake ~/dotfiles/nix#waist

# On WSL (Native NixOS-WSL)
sudo nixos-rebuild switch --flake ~/dotfiles/nix#wsl
```

