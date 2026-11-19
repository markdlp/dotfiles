{ ... }:

{
  flake.modules.nixos.desktop-apps =
    { pkgs, ... }:
    let
      openrocket = pkgs.callPackage ../../pkgs/openrocket/package.nix { };
      handy = pkgs.callPackage ../../pkgs/handy/package.nix { };
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

      # --- ZOTERO BETTER BIBTEX EXTENSION HOOK ---
      systemd.user.services.zotero-better-bibtex = {
        description = "Fetch and install latest Zotero Better BibTeX extension";
        wantedBy = [ "default.target" ];
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        path = with pkgs; [ curl coreutils findutils ];
        script = ''
          EXT_DIR="$HOME/.local/share/zotero-extensions"
          mkdir -p "$EXT_DIR"
          XPI_TARGET="$EXT_DIR/zotero-better-bibtex@iris-advies.com.xpi"

          if [ ! -f "$XPI_TARGET" ] || [ $(find "$XPI_TARGET" -mtime +14) ]; then
            curl -sSL "https://github.com/retorquere/zotero-better-bibtex/releases/latest/download/zotero-better-bibtex.xpi" -o "$XPI_TARGET.tmp" && \
            mv "$XPI_TARGET.tmp" "$XPI_TARGET"
          fi

          for p in $HOME/.zotero/zotero/*; do
            if [ -d "$p" ]; then
              mkdir -p "$p/extensions"
              ln -sf "$XPI_TARGET" "$p/extensions/zotero-better-bibtex@iris-advies.com.xpi"
            fi
          done
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

        # Productivity, Office & Knowledge
        obsidian
        logseq
        appflowy
        localsend
        zotero
        libreoffice-qt
        hunspell
        hunspellDicts.el-gr
        hunspellDicts.en-gb-large

        # Science & Engineering
        freecad
        kicad
        openrocket
        (pkgs.writeShellScriptBin "nelson" ''
          exec flatpak run io.github.nelson_lang.Nelson "$@"
        '')

        # Creative, Media & Production
        (wrapOBS {
          plugins = with obs-studio-plugins; [
            obs-vkcapture
            obs-pipewire-audio-capture
          ];
        })
        darktable
        handbrake
        musescore
        audacity
        ffmpeg
        spotify
        vlc
        stremio-linux-shell

        # Security & Password Management
        bitwarden-desktop

        # Utility & Development Tools
        handy
        rpi-imager
        angryipscanner
        prismlauncher
        jetbrains-toolbox
      ];
    }
  ;
}
