{ lib
, appimageTools
, fetchurl
}:

let
  pname = "handy";
  version = "0.10.1";

  src = fetchurl {
    url = "https://github.com/cjpais/Handy/releases/download/v${version}/Handy_${version}_amd64.AppImage";
    hash = "sha256-+J4me4mYPQaanL+nS16Tqj+gRFVwK4T7VaXmeSBIOV8=";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = pkgs: with pkgs; [
    webkitgtk_4_1
    glib
    gtk3
    cairo
    pango
    gdk-pixbuf
    libsoup_3
    openssl
    alsa-lib
    libayatana-appindicator
    xdotool
  ];

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/Handy.desktop $out/share/applications/handy.desktop 2>/dev/null || \
    install -m 444 -D ${appimageContents}/handy.desktop $out/share/applications/handy.desktop 2>/dev/null || true

    if [ -f "$out/share/applications/handy.desktop" ]; then
      substituteInPlace $out/share/applications/handy.desktop \
        --replace-fail 'Exec=Handy' 'Exec=handy' 2>/dev/null || true
    fi

    for icon in ${appimageContents}/usr/share/icons/hicolor/*/apps/*; do
      if [ -f "$icon" ]; then
        rel="''${icon#${appimageContents}/usr/share/icons/}"
        install -m 444 -D "$icon" "$out/share/icons/$rel"
      fi
    done
  '';

  meta = with lib; {
    description = "Free, open-source, and offline speech-to-text desktop application";
    homepage = "https://handy.computer";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "handy";
  };
}
