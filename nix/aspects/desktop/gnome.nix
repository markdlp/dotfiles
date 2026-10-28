{ ... }:

{
  flake.modules.nixos.desktop-gnome =
    { pkgs, ... }:
    {
      # --- X11 & GNOME DESKTOP ---
      services.xserver = {
        enable = true;
        xkb = {
          layout = "us";
          variant = "";
        };
      };

      services.displayManager.gdm.enable = true;
      services.desktopManager.gnome.enable = true;

      # Enable CUPS printing
      services.printing.enable = true;

      # --- SOUND (PIPEWIRE) ---
      services.pulseaudio.enable = false;
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };

      # --- GNOME SETTINGS & THEMES VIA DCONF ---
      programs.dconf.enable = true;
      programs.dconf.profiles.user.databases = [
        {
          settings = {
            "org/gnome/desktop/interface" = {
              icon-theme = "Papirus-Dark";
            };
            "org/gnome/shell" = {
              disable-user-extensions = false;
              enabled-extensions = [ "dash-to-panel@jderose9.github.com" ];
            };
            "org/gnome/shell/extensions/dash-to-panel" = {
              panel-position = "BOTTOM";
              intellihide = false;
            };
          };
        }
      ];

      environment.systemPackages = with pkgs; [
        gnomeExtensions.dash-to-panel
        papirus-icon-theme
      ];
    };
}
