{ lib
, stdenv
, fetchurl
, makeWrapper
, copyDesktopItems
, makeDesktopItem
, jre
, unzip
}:

let
  pname = "openrocket";
  version = "24.12";

  src = fetchurl {
    url = "https://github.com/openrocket/openrocket/releases/download/release-${version}/OpenRocket-${version}.jar";
    hash = "sha256-SVm3L1L19geUHpciq7t7fwxKOOu7+EIEoynbnzHE+Jc=";
  };

  desktopItem = makeDesktopItem {
    name = "openrocket";
    exec = "openrocket %F";
    icon = "openrocket";
    comment = "Model rocket simulator";
    desktopName = "OpenRocket";
    genericName = "Model Rocket Simulator";
    categories = [ "Education" "Science" "Engineering" ];
    mimeTypes = [ "application/x-openrocket" ];
    terminal = false;
  };
in
stdenv.mkDerivation {
  inherit pname version src;

  dontUnpack = true;

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
    unzip
  ];

  desktopItems = [ desktopItem ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/openrocket
    cp $src $out/share/openrocket/OpenRocket.jar

    mkdir -p $out/bin
    makeWrapper ${jre}/bin/java $out/bin/openrocket \
      --add-flags "--add-exports=java.base/java.lang=ALL-UNNAMED" \
      --add-flags "--add-exports=java.desktop/sun.awt=ALL-UNNAMED" \
      --add-flags "--add-exports=java.desktop/sun.java2d=ALL-UNNAMED" \
      --add-flags "--add-opens=java.base/java.lang=ALL-UNNAMED" \
      --add-flags "--add-opens=java.desktop/sun.awt=ALL-UNNAMED" \
      --add-flags "--add-opens=java.desktop/sun.java2d=ALL-UNNAMED" \
      --add-flags "-jar $out/share/openrocket/OpenRocket.jar"

    for size in 256 128 64 32; do
      mkdir -p $out/share/icons/hicolor/''${size}x''${size}/apps
      unzip -p $src pix/icon/icon-''${size}.png > $out/share/icons/hicolor/''${size}x''${size}/apps/openrocket.png 2>/dev/null || true
      [ -s $out/share/icons/hicolor/''${size}x''${size}/apps/openrocket.png ] || rm -f $out/share/icons/hicolor/''${size}x''${size}/apps/openrocket.png
    done

    runHook postInstall
  '';

  meta = with lib; {
    description = "Free, fully featured model rocket simulator";
    homepage = "https://openrocket.info/";
    license = licenses.gpl3Plus;
    platforms = platforms.unix;
    mainProgram = "openrocket";
  };
}
