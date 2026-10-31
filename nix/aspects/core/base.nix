{ ... }:

{
  flake.modules.nixos.core-base =
    { config, pkgs, ... }:
    {
      # --- NIX DAEMON & FLAKES ---
      nix.settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        trusted-users = [
          "root"
          "mark"
        ];
      };

      # Weekly automated garbage collection
      nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 20d";
      };

      # Allow proprietary software
      nixpkgs.config.allowUnfree = true;

      # --- TIME & LOCALIZATION ---
      time.timeZone = "Europe/Athens";

      i18n.defaultLocale = "en_US.UTF-8";
      i18n.extraLocaleSettings = {
        LC_ADDRESS = "el_GR.UTF-8";
        LC_IDENTIFICATION = "el_GR.UTF-8";
        LC_MEASUREMENT = "el_GR.UTF-8";
        LC_MONETARY = "el_GR.UTF-8";
        LC_NAME = "el_GR.UTF-8";
        LC_NUMERIC = "el_GR.UTF-8";
        LC_PAPER = "el_GR.UTF-8";
        LC_TELEPHONE = "el_GR.UTF-8";
        LC_TIME = "el_GR.UTF-8";
      };

      # --- LOCAL DISCOVERY (mDNS) ---
      services.avahi = {
        enable = true;
        nssmdns4 = true;
        settings = {
          publish = {
            publish-workstation = true;
            publish-addresses = true;
            disable-publishing = false;
          };
        };
      };
      # services.avahi.settings.publish."disable-publishing" = false;

      # --- SECURITY & PERMISSIONS ---
      security.sudo.wheelNeedsPassword = false;

      # Dynamic linking helper for unpatched pre-compiled binaries
      programs.nix-ld.enable = true;

      # --- COMMON CLI PACKAGES ---
      environment.systemPackages = with pkgs; [
        # Editors & viewers
        micro
        vim
        bat

        # Search & navigation
        ripgrep
        zoxide
        eza

        # Monitoring & dev tools
        btop
        fastfetch
        git
        gh
        nixfmt

        # Archives & networking utilities
        unzip
        zip
        wget
        curl
      ];
    };
}
