{ ... }:

{
  flake.modules.nixos.dev-gnuradio =
    { pkgs, ... }:
    {
      # Enable dconf service and D-Bus integration required by GTK3 / GRC
      programs.dconf.enable = true;

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

        # Terminal emulator for flowgraphs that spawn console windows
        xterm

        # x-terminal-emulator shim pointing to xterm for GNU Radio Companion
        (writeShellScriptBin "x-terminal-emulator" ''
          exec ${xterm}/bin/xterm "$@"
        '')

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
