# Dotfiles

This repository contains personal configuration files for multiple machines.

## Structure

- `windows/` - Declarative configuration and application manifests for Windows (managed with [chezmoi](https://www.chezmoi.io/) via `.chezmoiroot`).
- `nix/` - Declarative NixOS system configurations organized via the **Dendritic Pattern**.

## Windows Setup (Chezmoi & Winget)

Windows dotfiles and software packages are managed with **chezmoi** and **winget**. The `.chezmoiroot` file directs chezmoi to map the `windows/` directory to your home profile (`~`) automatically.

### Clean Setup on a New Windows Machine

1. **Install Chezmoi** (via PowerShell):

   ```powershell
   winget install twpayne.chezmoi
   ```

2. **Initialize and Apply Dotfiles**:

   ```powershell
   chezmoi init https://github.com/markdlp/dotfiles.git
   chezmoi apply
   ```

   *(This applies `.wslconfig` (mirrored networking), `.gitconfig` (LF & LFS), Zed, Windows Terminal palettes, VS Code settings, installs extensions from `vscode-extensions.txt`, installs all applications declared in `my-winget-packages.json`, and sets up PowerShell).*

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

##### 2. Remote Deploy to Waist (Raspberry Pi 4) via SSH

Deploy to remote hosts using `--target-host` and `--elevate=sudo`.

- **Waist (Raspberry Pi 4 - `aarch64-linux`):**
  Evaluated and built on PC via QEMU binfmt emulation, then pushed to the Pi over SSH:

  ```zsh
  nixos-rebuild switch --flake ~/dotfiles/nix\#waist \
    --target-host mark@waist.local \
    --elevate=sudo
  ```

  From Windows Powershell

  ```pwsh
    wsl -d nixos -- zsh -l -c "nixos-rebuild switch --flake /home/mark/dotfiles/nix#waist --target-host waist.local --elevate=sudo"
  ```

- **Body (Desktop Workstation - `x86_64-linux`):**
  When booted into Body (bare-metal dual-boot workstation), rebuild locally:

  ```zsh
  sudo nixos-rebuild switch --flake ~/dotfiles/nix\#body
  ```

> [!TIP]
>
> - **No local `sudo` needed**: When deploying remotely, do not run `sudo nixos-rebuild`; local `sudo` is only needed when switching the local WSL instance.
> - **Flags breakdown**:
>   - `--target-host`: The remote SSH target where the new system profile is activated.
>   - `--build-host`: Optional SSH builder host. Leave this unset so derivations are evaluated and built locally on your fast desktop CPU via QEMU binfmt and official binary caches, rather than burdening the Pi.
>   - `--elevate=sudo`: Runs activation commands on the remote target using `sudo` without needing root SSH logins (replaces deprecated `--use-remote-sudo`).
> - **Host resolution & WSL2 NAT**: Remote hosts use mDNS (`.local`) managed declaratively via Avahi in `core-base`. If WSL2 in standard NAT mode cannot resolve `.local` domains, substitute the LAN IP address (e.g., `mark@192.168.1.X`), define a host alias in `~/.ssh/config`, or set `networkingMode=mirrored` in `%USERPROFILE%\.wslconfig`.

##### 3. One-Liner from Windows PowerShell

You can also trigger these deployments directly from a Windows PowerShell prompt:

```powershell
# Rebuild local WSL
wsl -d nixos -u root -- zsh -l -c "nixos-rebuild switch --flake /home/mark/dotfiles/nix#wsl"

# Remote rebuild Waist (Pi 4)
wsl -d nixos -- zsh -l -c "nixos-rebuild switch --flake /home/mark/dotfiles/nix#waist --target-host mark@waist.local --elevate=sudo"
```

#### On-Device Local Rebuild (Fallback)

If you are physically logged into the target machine:

```zsh
# On Body (Desktop)
sudo nixos-rebuild switch --flake ~/dotfiles/nix\#body

# On Waist (Raspberry Pi 4)
sudo nixos-rebuild switch --flake ~/dotfiles/nix\#waist
```

### Detached & Background Deployments (Tmux & `job-run`)

Long-running commands (such as compiling the kernel for Waist or large system builds) can be launched in persistent, detached tmux sessions so you can close your terminal, disconnect, or monitor progress at your convenience.

#### 1. Fire-and-Forget Background Aliases

```zsh
# Rebuild Waist in background with persistent logs & desktop notification on finish
rebuild-waist-bg

# Rebuild Body in background
rebuild-body-bg

# Rebuild WSL in background
rebuild-wsl-bg
```

#### 2. Running Custom Tasks with `job-run`

```zsh
# Spawn detached with custom session name
job-run -s my-build "command to run"

# Spawn and attach immediately (Ctrl-Space then d to detach anytime)
job-run -a -s kernel-compile "make -j$(nproc)"
```

- **Logs**: Preserved automatically in `~/.local/state/tmux-jobs/<session>-<timestamp>.log`.
- **Completion**: Sends a desktop notification via `notify-send`, rings the terminal bell, and preserves the window with exit code and duration until you press `[Enter]`.

#### 3. Remote Session Management (`ssh-tmux`)

Safely attach or create a persistent tmux session on remote hosts without breaking non-interactive automation:

```zsh
# Connect to Waist with persistent 'main' session
ssh-tmux waist.local

# Connect to a named session
ssh-tmux waist.local kernel-work
```

#### 4. Tmux Keybindings Reference

- **Prefix**: `Ctrl-Space`
- **Fuzzy Workspace Switcher**: `Ctrl-Space` + `f` (runs `tmux-sessionizer` with `fzf`)
- **Vertical Split**: `Ctrl-Space` + `|` (opens in current working directory)
- **Horizontal Split**: `Ctrl-Space` + `-` (opens in current working directory)
- **New Window**: `Ctrl-Space` + `c` (opens in current working directory)
- **Vim Navigation**: `Ctrl-Space` + `h` / `j` / `k` / `l`
- **Vi Copy Mode**: `Ctrl-Space` + `[` (`v` to select, `y` to copy to system clipboard via OSC 52)
- **Detach Session**: `Ctrl-Space` + `d`
- **Reattach**: `tmux attach` or `tmux attach -t <name>`

