{ inputs, config, ... }:

{
  flake.nixosConfigurations."wsl" = inputs.nixpkgs-unstable.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      # Dendritic Aspects
      config.flake.modules.nixos.core-base
      config.flake.modules.nixos.core-users
      config.flake.modules.nixos.core-zsh
      config.flake.modules.nixos.wsl
      config.flake.modules.nixos.dev-gnuradio
      config.flake.modules.nixos.dev-java

      # Host-specific settings
      (
        { ... }:
        {
          networking.hostName = "wsl";
          system.stateVersion = "25.11";
        }
      )
    ];
  };
}
