{ inputs, ... }:

{
  flake.modules.nixos.desktop-apps =
    { pkgs, ... }:
    let
      agPkgs = inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system};
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
        audacity

        # Security & Password Management
        bitwarden-desktop

        # Utility & Development Tools
        rpi-imager
        angryipscanner
        prismlauncher
        jetbrains-toolbox
        agPkgs.google-antigravity
        agPkgs.google-antigravity-cli
        agPkgs.google-antigravity-ide
      ];
    }
  ;
}
