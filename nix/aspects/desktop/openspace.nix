{ ... }:

{
  flake.modules.nixos.desktop-openspace =
    { pkgs, ... }:
    let
      openspace = pkgs.callPackage ../../pkgs/openspace/package.nix { };
    in
    {
      # --- OPENSPACE (ASTRONOMY & VISUALIZATION ENGINE) ---
      environment.systemPackages = [
        openspace
      ];
    };
}
