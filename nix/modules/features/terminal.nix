{ inputs, ... }: {
  perSystem = { pkgs, ... }: {
    packages.myKitty = inputs.wrapper-modules.wrappers.kitty.wrap {
      inherit pkgs;
      
      # Links your existing kitty configuration directly into the wrapper
      configFile = ../../hosts/body/kitty.conf;
      
      # Example environment variable injection handled at the binary level
      env = {
        TERM = "xterm-kitty";
      };
    };
  };
}