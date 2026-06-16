{ self, inputs, ... }: {
  flake.nixosConfigurations.body = inputs.nixpkgs.lib.nixosSystem {
    
    # Pass inputs to your NixOS modules just like you did in your old flake!
    specialArgs = { inherit inputs; };

    modules = [
      # Go up two directories (out of hosts, out of flake-root)
      ../../hosts/body/hardware-configuration.nix
      ../../hosts/body/configuration.nix
      
      # Your nvidia module is safe here
      ../../modules/nvidia.nix

      ({ pkgs, ... }: {
        environment.systemPackages = [
          self.packages.${pkgs.system}.myKitty
        ];
      })
    ];
  };
}