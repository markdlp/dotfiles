{ inputs, ... }:

{
  flake.modules.nixos.dev-antigravity =
    { pkgs, ... }:
    let
      system = pkgs.stdenv.hostPlatform.system;
      llmPkgs = inputs.llm-agents.packages.${system};
      pkgsUnstable = import inputs.nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      # --- GOOGLE ANTIGRAVITY (IDE, HUB & CLI) ---
      environment.systemPackages = [
        # Antigravity CLI (agy)
        llmPkgs.antigravity-cli

        # Antigravity Hub (Desktop Agent Manager from llm-agents.nix)
        llmPkgs.antigravity-hub

        # Convenience alias binary for antigravity-hub
        (pkgs.runCommand "antigravity-hub-bin" { } ''
          mkdir -p $out/bin
          ln -s ${llmPkgs.antigravity-hub}/bin/antigravity $out/bin/antigravity-hub
        '')

        # Antigravity IDE (VS Code-based AI editor with FHS from nixpkgs-unstable)
        pkgsUnstable.antigravity-ide-fhs
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

