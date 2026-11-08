{ inputs, ... }:

{
  flake.modules.nixos.dev-antigravity =
    { pkgs, ... }:
    let
      system = pkgs.stdenv.hostPlatform.system;
      llmPkgs = inputs.llm-agents.packages.${system};
    in
    {
      # --- GOOGLE ANTIGRAVITY (IDE & CLI) ---
      environment.systemPackages = [
        # Antigravity CLI (agy)
        llmPkgs.antigravity-cli

        # Antigravity IDE / Hub
        (llmPkgs.antigravity-ide or llmPkgs.antigravity-hub)
      ];

      # --- NUMTIDE BINARY CACHE ---
      nix.settings = {
        extra-substituters = [
          "https://cache.numtide.com"
        ];
        extra-trusted-public-keys = [
          "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
        ];
      };
    };
}

