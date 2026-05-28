{ inputs, ... }:

{
  # 1. BARE METAL NIXOS (No Home Manager)
  flake.nixosConfigurations = {
    "body" = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      
      # Pass inputs down to your modules
      specialArgs = { inherit inputs; };
      
      modules = [
        ./body/hardware-configuration.nix
        ./body/configuration.nix
        
        ../modules/nvidia.nix
      ];
    };

    "waist" = inputs.nixpkgs-unstable.lib.nixosSystem {
      system = "aarch64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./waist/hardware-configuration.nix
        ./waist/configuration.nix

        inputs.nixos-hardware.nixosModules.raspberry-pi-4
      ];
    };
  };

  # 2. WSL ENVIRONMENT (Home Manager Only)
  flake.homeConfigurations = {
    "mark" = inputs.home-manager.lib.homeManagerConfiguration {
      # Instantiate pkgs for standalone Home Manager
      pkgs = import inputs.nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
      
      # Pass inputs down to your modules
      extraSpecialArgs = { inherit inputs; };
      
      modules = [
        # Path to your existing WSL config
        ./wsl/home.nix
      ];
    };
  };
}