{ ... }:

{
  flake.modules.nixos.core-zsh =
    { pkgs, ... }:
    {
      # --- ZSH & OH-MY-ZSH ---
      programs.zsh = {
        enable = true;

        shellInit = ''
          if [ -d "$HOME/.cache/oh-my-zsh/completions" ]; then
            chmod -R u+w "$HOME/.cache/oh-my-zsh/completions" 2>/dev/null || true
          fi
        '';

        ohMyZsh = {
          enable = true;
          plugins = [
            "git"
            "sudo"
            "docker"
          ];
        };

        # Standardized modern shell prompt with Oh-My-Posh (atomic theme)
        promptInit = ''
          eval "$(${pkgs.oh-my-posh}/bin/oh-my-posh init zsh --config ${pkgs.oh-my-posh}/share/oh-my-posh/themes/atomic.omp.json)"
        '';

        shellAliases = {
          cat = "bat";
          nano = "micro";
          ls = "ls --color=auto";
          ll = "ls -la";
        };
      };

      environment.systemPackages = with pkgs; [
        oh-my-posh
      ];

      # --- NERD FONTS FOR TERMINAL ICONS ---
      fonts.packages = with pkgs; [
        nerd-fonts.meslo-lg
        nerd-fonts.fira-code
      ];
    };
}
