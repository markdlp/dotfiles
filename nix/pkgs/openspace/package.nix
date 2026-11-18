{ lib
, appimageTools
, fetchurl
, makeDesktopItem
}:

let
  pname = "openspace";
  version = "0.21.2-1";

  src = fetchurl {
    url = "https://github.com/hn-88/OpenSpace-AppImage/releases/download/v${version}/OpenSpace-${version}-x86_64.AppImage";
    hash = "sha256-mqFIl5NZW4vZgETtc6/mouuecD4eLU+RVuKmd98b2Sw=";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
    postExtract = ''
      rm -f $out/lib/x86_64-linux-gnu/libstdc++.so.6
      rm -f $out/lib/x86_64-linux-gnu/libgcc_s.so.1
    '';
  };

  desktopItem = makeDesktopItem {
    name = "openspace";
    exec = "openspace %U";
    icon = "OpenSpace";
    comment = "Interactive data visualization software to visualize the known universe";
    desktopName = "OpenSpace";
    genericName = "Astronomy Visualization Software";
    categories = [ "Education" "Science" "Astronomy" ];
    terminal = false;
  };

  wrapperScript = ./openspace-wrapper.sh;
in
appimageTools.wrapAppImage {
  inherit pname version;
  src = appimageContents;

  extraPkgs = pkgs: with pkgs; [
    alsa-lib
    at-spi2-core
    cairo
    cups
    dbus
    e2fsprogs
    expat
    fontconfig
    freetype
    fribidi
    gdk-pixbuf
    glib
    gmp
    harfbuzz
    libdrm
    libglvnd
    libgpg-error
    libice
    libjack2
    libsm
    libusb1
    libx11
    libxcb
    libxcb-cursor
    libxcb-image
    libxcb-keysyms
    libxcb-render-util
    libxcb-util
    libxcb-wm
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxinerama
    libxkbcommon
    libxrandr
    libxxf86vm
    mesa
    mpv
    nspr
    nss
    p11-kit
    pango
    vulkan-loader
    zlib
  ];

  extraInstallCommands = ''
    install -m 444 -D ${desktopItem}/share/applications/openspace.desktop $out/share/applications/openspace.desktop
    install -m 444 -D ${appimageContents}/OpenSpace.png $out/share/icons/hicolor/256x256/apps/OpenSpace.png
    install -m 444 -D ${appimageContents}/OpenSpace.png $out/share/icons/hicolor/256x256/apps/openspace.png
    install -m 444 -D ${appimageContents}/OpenSpace64.png $out/share/icons/hicolor/64x64/apps/OpenSpace.png
    install -m 444 -D ${appimageContents}/OpenSpace64.png $out/share/icons/hicolor/64x64/apps/openspace.png

    mv $out/bin/${pname} $out/bin/.${pname}-wrapped
    install -m 755 ${wrapperScript} $out/bin/${pname}
    substituteInPlace $out/bin/${pname} \
      --replace-fail '@RAW_OPENSPACE@' "$out/bin/.${pname}-wrapped" \
      --replace-fail '@EXTRACTED_APPDIR@' "${appimageContents}"
  '';

  meta = with lib; {
    description = "Open-source interactive data visualization software designed to visualize the entire known universe";
    homepage = "https://www.openspaceproject.com";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "openspace";
  };
}
