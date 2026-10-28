{ ... }:

{
  flake.modules.nixos.dev-gnuradio =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        # --- GNU Radio with SDR hardware support and Python bindings ---
        (gnuradio.override {
          extraPackages = with gnuradioPackages; [
            osmosdr
          ];
          extraPythonPackages = with gnuradio.python.pkgs; [
            numpy
            pyqt5
          ];
        })

        # Desktop entry for application launcher
        (makeDesktopItem {
          name = "gnuradio-companion";
          desktopName = "GNU Radio Companion";
          exec = "gnuradio-companion";
          icon = "gnuradio-grc";
          comment = "Software Defined Radio framework";
          categories = [
            "Development"
            "Engineering"
            "Science"
          ];
          startupWMClass = "gnuradio-companion";
        })
      ];
    };
}
