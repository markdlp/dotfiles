{ inputs, config, ... }:

{
  flake.nixosConfigurations."wsl" = inputs.nixpkgs-unstable.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      # Core Aspects
      config.flake.modules.nixos.core-common
      config.flake.modules.nixos.wsl
      config.flake.modules.nixos.dev-gnuradio
      config.flake.modules.nixos.dev-java
      config.flake.modules.nixos.dev-antigravity

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
