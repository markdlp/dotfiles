{ inputs, config, ... }:

{
  flake.nixosConfigurations."waist" = inputs.nixpkgs-unstable.lib.nixosSystem {
    system = "aarch64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      inputs.nixos-hardware.nixosModules.raspberry-pi-4
      ./hardware-configuration.nix

      # Dendritic Aspects
      config.flake.modules.nixos.core-base
      config.flake.modules.nixos.core-users
      config.flake.modules.nixos.core-zsh
      config.flake.modules.nixos.hardware-rpi
      config.flake.modules.nixos.virtualisation-docker

      # Host-specific settings
      (
        { ... }:
        {
          networking.hostName = "waist";
          system.stateVersion = "26.05";
        }
      )
    ];
  };
}
