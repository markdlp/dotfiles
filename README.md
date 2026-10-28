# Dotfiles

This repository contains personal configuration files for multiple machines.

## Structure

- `windows/` - Declarative configuration and application manifests for Windows (managed with [chezmoi](https://www.chezmoi.io/) via `.chezmoiroot`).
- `nix/` - Declarative NixOS system configurations organized via the **Dendritic Pattern**.

## Windows Setup (Chezmoi & Winget)

Windows dotfiles and software packages are managed with **chezmoi** and **winget**. The `.chezmoiroot` file directs chezmoi to map the `windows/` directory to your home profile (`~`) automatically.

### Clean Setup on a New Windows Machine:

1. **Install Chezmoi** (via PowerShell):
   ```powershell
   winget install twpayne.chezmoi
   ```

2. **Initialize and Apply Dotfiles**:
   ```powershell
   chezmoi init https://github.com/markdlp/dotfiles.git
   chezmoi apply
   ```
   *(This applies Windows Terminal and VS Code configurations, installs all applications declared in `my-winget-packages.json`, and sets up PowerShell).*

3. **Restore SSH Private Keys from Bitwarden**:
   ```powershell
   # Unlock Bitwarden session
   $env:BW_SESSION = (bw unlock --raw)
   # Download keys and lock down ACLs
   powershell -File "$HOME\restore_ssh_keys.ps1"
   ```

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
