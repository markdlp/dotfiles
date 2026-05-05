{ config, pkgs, ... }:

{
  home.username = "mark";
  home.homeDirectory = "/home/mark";
  home.stateVersion = "24.05";

  # Here is where you add your packages
  home.packages = with pkgs; [
    cryptsetup
    git
    micro
    bat
    gh
    zip
    unzip
    fastfetch
    lvm2
    nixfmt

    # --- GNU Radio Setup ---
    # We override the base package to inject extra SDR hardware support and Python libs
    (gnuradio.override {
      extraPackages = with gnuradioPackages; [

      ];
      extraPythonPackages = with gnuradio.python.pkgs; [
        numpy
      ];
    })
  ];

  # --- 2. ZSH SETUP ---
  programs.zsh = {
    enable = true;

    # Enable Oh My Zsh
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "sudo"
        "docker"
        "direnv"
      ];
      # Do NOT set a theme here, because we are using Powerlevel10k below
    };

    enableCompletion = true;
    # autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      cat = "bat";
      nano = "micro";
      ls = "ls --color=auto";
    };

    # Inject Powerlevel10k as a plugin
    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];

    initExtra = ''
      # fastfetch
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh     # Source the p10k config file if it exists

      # Custom aliases
      alias update="home-manager switch --flake ~/dotfiles/nix#mark"
      alias ll="ls -la"
    '';
  };

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
}
