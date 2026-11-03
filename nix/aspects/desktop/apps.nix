{ inputs, ... }:

{
  flake.modules.nixos.desktop-apps =
    { pkgs, ... }:
    let
      pkgs-unstable = import inputs.nixpkgs-unstable {
        inherit (pkgs.stdenv.hostPlatform) system;
        config.allowUnfree = true;
      };
    in
    {
      # --- FIREFOX WITH PWA SUPPORT ---
      programs.firefox = {
        enable = true;
        package = pkgs.firefox;
        nativeMessagingHosts.packages = [ pkgs.firefoxpwa ];
      };

      # --- KITTY TERMINAL CONFIGURATION ---
      environment.etc."xdg/kitty/kitty.conf".source = ./kitty.conf;

      environment.localBinInPath = true;

      # --- GUI & DESKTOP APPLICATIONS ---
      environment.systemPackages = with pkgs; [
        # Terminal & Editors
        kitty
        kitty.terminfo
        vscode
        neovim

        # Web & Internet
        firefoxpwa
        thunderbird
        transmission_4-gtk

        # Productivity & Office
        obsidian
        localsend
        freecad
        zotero
        libreoffice-qt
        hunspell
        hunspellDicts.el-gr
        hunspellDicts.en-gb-large

        # Media & Entertainment
        spotify
        vlc
        stremio-linux-shell

        # Security & Password Management
        bitwarden-desktop

        # Utility & Development Tools
        rpi-imager
        angryipscanner
        prismlauncher
        jetbrains-toolbox
        pkgs-unstable.antigravity-ide-fhs
      ];
    };
}
