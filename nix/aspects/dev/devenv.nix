{ ... }:

{
  flake.modules.nixos.dev-devenv =
    { pkgs, ... }:
    {
      # --- DEVENV & CACHIX CLI ---
      environment.systemPackages = with pkgs; [
        devenv
        cachix
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
