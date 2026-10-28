{ ... }:

{
  flake.modules.nixos.dev-java =
    { pkgs, ... }:
    {
      programs.java = {
        enable = true;
        package = pkgs.temurin-bin-25;
      };
    };
}
