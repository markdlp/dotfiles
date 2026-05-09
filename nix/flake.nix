{
  description = "Mark's Unified System Configurations";

  inputs = {
    # NixOS package sources
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

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
      systems = [ "x86_64-linux" ];

      # Route to the hosts directory
      imports = [
        ./hosts
      ];
    };
}
