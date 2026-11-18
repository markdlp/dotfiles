{ ... }:

{
  flake.modules.nixos.desktop-apps =
    { pkgs, ... }:
    let
      openrocket = pkgs.callPackage ../../pkgs/openrocket/package.nix { };
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

      # --- FLATPAK SUPPORT (NELSON NUMERICAL SOFTWARE) ---
      services.flatpak.enable = true;

      systemd.services.flatpak-repo-flathub = {
        description = "Configure Flathub repository and install Nelson";
        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        path = [ pkgs.flatpak ];
        script = ''
          flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
          flatpak install -y --noninteractive flathub io.github.nelson_lang.Nelson || true
        '';
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
      };

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

        # Science & Engineering
        openrocket
        (pkgs.writeShellScriptBin "nelson" ''
          exec flatpak run io.github.nelson_lang.Nelson "$@"
        '')

        # Media & Entertainment
        spotify
        vlc
        stremio-linux-shell
        audacity
        ffmpeg

        # Security & Password Management
        bitwarden-desktop

        # Utility & Development Tools
        rpi-imager
        angryipscanner
        prismlauncher
        jetbrains-toolbox
      ];
    }
  ;
}
