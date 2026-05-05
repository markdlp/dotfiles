{ inputs, ... }:

{
  # 1. BARE METAL NIXOS (No Home Manager)
  flake.nixosConfigurations = {
    "body" = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      
      # Pass inputs down to your modules
      specialArgs = { inherit inputs; };
      
      modules = [
        # Assuming you renamed the 'nixos' folder to 'body'
        ./body/hardware-configuration.nix
        ./body/configuration.nix
        
        # When you are ready for the OMEN, you can add your NVIDIA module here:
        # ../modules/nvidia.nix
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