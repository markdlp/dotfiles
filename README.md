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

Configurations can be deployed and switched directly from your **Windows (NixOS-WSL)** environment over SSH, or locally on each physical machine.

#### From Windows (NixOS-WSL)

From within your NixOS-WSL terminal (pointing to your dotfiles repository):

##### 1. Rebuild Local WSL
```zsh
sudo nixos-rebuild switch --flake ~/dotfiles/nix\#wsl
```

##### 2. Remote Deploy via SSH
Deploy to remote hosts using `--target-host` and `--elevate=sudo`.

- **Waist (Raspberry Pi 4 - `aarch64-linux`):**
  Uses `--build-host` to build derivations directly on the Pi, avoiding `x86_64` to `aarch64` cross-compilation on WSL:
  ```zsh
  nixos-rebuild switch --flake ~/dotfiles/nix\#waist \
    --target-host mark@waist.local \
    --build-host mark@waist.local \
    --elevate=sudo
  ```

- **Body (Desktop Workstation - `x86_64-linux`):**
  Uses `--build-host` to offload the build to the workstation's hardware:
  ```zsh
  nixos-rebuild switch --flake ~/dotfiles/nix\#body \
    --target-host mark@body.local \
    --build-host mark@body.local \
    --elevate=sudo
  ```

> [!TIP]
> - **No local `sudo` needed**: When deploying remotely, do not run `sudo nixos-rebuild`; local `sudo` is only needed when switching the local WSL instance.
> - **Flags breakdown**:
>   - `--target-host`: The remote SSH target where the new system profile is activated.
>   - `--build-host`: The SSH host where derivations are built (crucial for cross-architecture targets like the Raspberry Pi).
>   - `--elevate=sudo`: Runs activation commands on the remote target using `sudo` without needing root SSH logins (replaces deprecated `--use-remote-sudo`).
> - **Host resolution & WSL2 NAT**: Remote hosts use mDNS (`.local`) managed declaratively via Avahi in `core-base`. If WSL2 in standard NAT mode cannot resolve `.local` domains, substitute the LAN IP address (e.g., `mark@192.168.1.X`), define a host alias in `~/.ssh/config`, or set `networkingMode=mirrored` in `%USERPROFILE%\.wslconfig`.

##### 3. One-Liner from Windows PowerShell
You can also trigger these deployments directly from a Windows PowerShell prompt:

```powershell
# Rebuild local WSL
wsl sudo nixos-rebuild switch --flake ~/dotfiles/nix\#wsl

# Remote rebuild Waist (Pi 4)
wsl nixos-rebuild switch --flake ~/dotfiles/nix\#waist --target-host mark@waist.local --build-host mark@waist.local --elevate=sudo

# Remote rebuild Body (Desktop)
wsl nixos-rebuild switch --flake ~/dotfiles/nix\#body --target-host mark@body.local --build-host mark@body.local --elevate=sudo
```

#### On-Device Local Rebuild (Fallback)

If you are physically logged into the target machine:

```zsh
# On Body (Desktop)
sudo nixos-rebuild switch --flake ~/dotfiles/nix\#body

# On Waist (Raspberry Pi 4)
sudo nixos-rebuild switch --flake ~/dotfiles/nix\#waist
```
