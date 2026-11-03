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

        # Standardized modern shell prompt with Oh-My-Posh (Catppuccin Mocha theme)
        promptInit = ''
          eval "$(${pkgs.oh-my-posh}/bin/oh-my-posh init zsh --config ${pkgs.oh-my-posh}/share/oh-my-posh/themes/catppuccin_mocha.omp.json)"
        '';

        shellAliases = {
          cat = "bat";
          nano = "micro";
          ls = "ls --color=auto";
          ll = "ls -la";

          # Detached background rebuilds & session helpers
          rebuild-waist-bg = "job-run -s rebuild-waist 'nixos-rebuild switch --flake ~/dotfiles/nix#waist --target-host waist.local --sudo'";
          rebuild-body-bg = "job-run -s rebuild-body 'sudo nixos-rebuild switch --flake ~/dotfiles/nix#body'";
          rebuild-wsl-bg = "job-run -s rebuild-wsl 'sudo nixos-rebuild switch --flake ~/dotfiles/nix#wsl'";
        };
      };

      environment.systemPackages = with pkgs; [
        oh-my-posh
      ];

      # --- NERD FONTS FOR TERMINAL ICONS ---
      fonts = {
        packages = with pkgs; [
          nerd-fonts.meslo-lg
          nerd-fonts.fira-code
        ];

        fontconfig = {
          enable = true;
          defaultFonts = {
            monospace = [
              "MesloLGS Nerd Font Mono"
              "FiraCode Nerd Font Mono"
              "DejaVu Sans Mono"
            ];
          };
        };
      };
    };
}
