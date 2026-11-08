{ inputs, ... }:

{
  flake.modules.nixos.dev-devenv =
    { pkgs, ... }:
    let
      pkgsUnstable = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      # --- DEVENV & CACHIX CLI ---
      environment.systemPackages = [
        pkgsUnstable.devenv
        pkgsUnstable.cachix
      ];

      # --- DEVENV CACHIX BINARY CACHE ---
      nix.settings = {
        extra-substituters = [
          "https://devenv.cachix.org"
        ];
        extra-trusted-public-keys = [
          "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        ];
      };

      # --- DIRENV INTEGRATION ---
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
    };
}
