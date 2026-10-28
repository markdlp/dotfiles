{ ... }:

{
  flake.modules.nixos.desktop-apps =
    { pkgs, ... }:
    {
      # --- FIREFOX WITH PWA SUPPORT ---
      programs.firefox = {
        enable = true;
        package = pkgs.firefox;
        nativeMessagingHosts.packages = [ pkgs.firefoxpwa ];
      };

      # --- KITTY TERMINAL CONFIGURATION ---
      environment.etc."xdg/kitty/kitty.conf".source = ./kitty.conf;

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

        # Productivity & Office
        obsidian
        freecad
        zotero
        libreoffice-qt
        hunspell
        hunspellDicts.el-gr
        hunspellDicts.en-gb-large

        # Media & Entertainment
        spotify
        vlc

        # Security & Password Management
        bitwarden-desktop

        # Utility & Development Tools
        rpi-imager
        angryipscanner
        prismlauncher
        jetbrains-toolbox
      ];
    };
}
