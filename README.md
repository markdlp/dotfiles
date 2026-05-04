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

## NixOS

The `nixos/` folder contains NixOS-specific configuration and modules.

Use this directory as the base for NixOS system configuration and import it into your NixOS configuration.

## Notes

- Keep machine-specific files in their respective folders.
- Use the appropriate setup process for each platform.
