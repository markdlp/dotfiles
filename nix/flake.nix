{
  description = "Mark's Unified System Configurations";

  inputs = {
    # NixOS package sources (Existing stable branch for WSL/etc)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11"; 

    # NEW: Unstable branch specifically for the Raspberry Pi 4
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home Manager (Used for WSL)
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11"; 
      inputs.nixpkgs.follows = "nixpkgs"; 
    };

    # Flake-parts for the dendritic structure
    flake-parts.url = "github:hercules-ci/flake-parts"; 

    # NixVirt for declarative KVM management
    NixVirt = {
      url = "https://flakehub.com/f/AshleyYakeley/NixVirt/*.tar.gz"; 
      inputs.nixpkgs.follows = "nixpkgs"; 
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } { 
      # NEW: Added "aarch64-linux" to support the Pi
      systems = [ "x86_64-linux" "aarch64-linux" ]; 

      # Route to the hosts directory
      imports = [
        ./hosts 
      ];
    }; 
}