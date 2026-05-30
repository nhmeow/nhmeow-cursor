{
  stdenv,
  lib,
  xcursorgen,
  librsvg,
  hyprcursor,
  ...
}:
let
  pname = "nhmeow-cursor";
  version = "0.1.0";
  themeName = "nhmeow-cursor";
  sizes = [
    24
    32
    48
    64
  ];

  cursorDefs = import ./cursors.nix;

  build = import ./build.nix {
    inherit
      lib
      themeName
      version
      sizes
      cursorDefs
      ;
  };

in
stdenv.mkDerivation {
  inherit pname version;
  src = ./src;

  nativeBuildInputs = [
    xcursorgen
    librsvg
    hyprcursor
  ];

  buildPhase = ''
    srcDir="$PWD"
    mkdir -p xcur

    ${build.xcursorBuild}

    mkdir -p hypr-work
    cd hypr-work
    ${build.hyprBuild}
    mkdir -p hypr-out
    hyprcursor-util --create . -o hypr-out
    cd "$srcDir"
  '';

  installPhase = ''
    mkdir -p $out/share/icons/${themeName}

    cp ${build.indexTheme} $out/share/icons/${themeName}/index.theme
    cp -r xcur $out/share/icons/${themeName}/cursors

    for d in hypr-work/hypr-out/*${themeName}*; do
      if [ -d "$d" ]; then
        cp -rn "$d"/* $out/share/icons/${themeName}/
      fi
    done
  '';

  meta = with lib; {
    description = "nhmeow cursor theme (XCursor + Hyprcursor)";
    homepage = "https://github.com/nhmeow/nhmeow-cursor";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
