{
  lib,
  themeName,
  version,
  sizes,
  cursorDefs,
}:
let
  sizesStr = builtins.concatStringsSep " " (map builtins.toString sizes);

  mkMetaHl =
    def:
    let
      lines = map (o: "define_override = ${o}") def.overrides;
    in
    builtins.toFile "${def.name}.meta.hl" ''
      resize_algorithm = bilinear
      hotspot_x = ${builtins.toString def.hx}
      hotspot_y = ${builtins.toString def.hy}
      ${builtins.concatStringsSep "\n" lines}
      define_size = 0, ${def.svg}
    '';

  manifestHl = builtins.toFile "manifest.hl" ''
    name = ${themeName}
    description = nhmeow cursor theme
    version = ${version}
    cursors_directory = hyprcursors
  '';

  indexTheme = builtins.toFile "index.theme" ''
    [Icon Theme]
    Name=${themeName}
    Comment=nhmeow cursor theme
    Inherits=
  '';

  xcursorOne =
    def:
    let
      aliases = builtins.filter (o: o != def.name) def.overrides;
    in
    ''
        for sz in ${sizesStr}; do
          px=$(awk "BEGIN { printf \"%d\", ${builtins.toString def.hx} * sz }")
          py=$(awk "BEGIN { printf \"%d\", ${builtins.toString def.hy} * sz }")
          rsvg-convert -w "$sz" -h "$sz" ${lib.escapeShellArg def.svg} -o "${def.name}_''${sz}.png"
          echo "$sz $px $py ${def.name}_''${sz}.png" >> "${def.name}.cfg"
        done
        xcursorgen "${def.name}.cfg" "xcur/${def.name}"
        rm -f "${def.name}.cfg" ${
          builtins.concatStringsSep " " (map (size: "${def.name}_${builtins.toString size}.png") sizes)
        }
      ${builtins.concatStringsSep "\n" (map (a: "      ln -sf ${def.name} xcur/${a}") aliases)}
    '';

  xcursorBuild = builtins.concatStringsSep "\n" (map xcursorOne cursorDefs);

  hyprBuild = ''
      cp ${manifestHl} manifest.hl
    ${builtins.concatStringsSep "\n" (
      map (def: ''
        mkdir -p hyprcursors/${def.name}
        cp ../${lib.escapeShellArg def.svg} hyprcursors/${def.name}/
        cp ${mkMetaHl def} hyprcursors/${def.name}/meta.hl
      '') cursorDefs
    )}
  '';

in
{
  inherit indexTheme xcursorBuild hyprBuild;
}
