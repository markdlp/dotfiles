{ self, inputs, ... }: {
  flake.nixosConfigurations.body = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      # Points to your existing configuration files
      ../../hosts/body/hardware-configuration.nix
      ../../hosts/body/configuration.nix
      
      # Inject system-wide configuration blocks here
      ({ pkgs, ... }: {
        environment.systemPackages = [
          # Links the wrapped terminal bundle from this flake into your system path
          self.packages.${pkgs.system}.myKitty
        ];
      })
    ];
  };
}