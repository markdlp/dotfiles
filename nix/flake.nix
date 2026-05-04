{
  description = "Mark's Unified System Configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }: {
    
    # 1. BARE METAL NIXOS (No Home Manager)
    nixosConfigurations = {
      "marks-desktop" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./nixos/configuration.nix
          ./nixos/hardware-configuration.nix
        ];
      };
    };

    # 2. WSL ENVIRONMENT (Home Manager Only)
    homeConfigurations = {
      "mark" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
        modules = [
          ./wsl/home.nix
        ];
      };
    };
  };
}