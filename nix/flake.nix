{
  description = "Mark's Unified System Configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Flake-parts modular framework
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Tree importer for dendritic auto-discovery
    import-tree.url = "github:denful/import-tree";

    # NixOS on WSL support
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Declarative KVM management for Body
    NixVirt = {
      url = "https://flakehub.com/f/AshleyYakeley/NixVirt/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, import-tree, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      imports = [
        inputs.flake-parts.flakeModules.modules
        (import-tree ./aspects)
        ./hosts
      ];
    };
}