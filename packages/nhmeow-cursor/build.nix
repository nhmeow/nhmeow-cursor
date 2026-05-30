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
            px=$(awk "BEGIN { printf \"%.0f\", ${builtins.toString def.hx} * sz }")
            py=$(awk "BEGIN { printf \"%.0f\", ${builtins.toString def.hy} * sz }")
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
        sed -e 's|width="312"|width="32"|' -e 's|width="312px"|width="32"|' \
            -e 's|height="312"|height="32"|' -e 's|height="312px"|height="32"|' \
            -e 's|<svg |<svg viewBox="0 0 312 312" |' \
          ../${lib.escapeShellArg def.svg} > hyprcursors/${def.name}/${def.svg}
        cp ${mkMetaHl def} hyprcursors/${def.name}/meta.hl
      '') cursorDefs
    )}
  '';

  kdeSvgBuild =
    let
      nominalSize = 24;
      svgSize = 312;
    in
    ''
        mkdir -p cursors_scalable
      ${builtins.concatStringsSep "\n" (
        map (
          def:
          let
            aliases = builtins.filter (o: o != def.name) def.overrides;
          in
          ''
            mkdir -p cursors_scalable/${def.name}
            sed -e 's|width="312"|width="32"|' -e 's|width="312px"|width="32"|' \
                -e 's|height="312"|height="32"|' -e 's|height="312px"|height="32"|' \
                -e 's|<svg |<svg viewBox="0 0 312 312" |' \
              ../${lib.escapeShellArg def.svg} > cursors_scalable/${def.name}/${def.name}.svg
            hx=$(awk "BEGIN { printf \"%.0f\", ${builtins.toString def.hx} * ${builtins.toString svgSize} }")
            hy=$(awk "BEGIN { printf \"%.0f\", ${builtins.toString def.hy} * ${builtins.toString svgSize} }")
            cat > cursors_scalable/${def.name}/metadata.json << JSONEOF
            [
              {
                "filename": "${def.name}.svg",
                "hotspot_x": $hx,
                "hotspot_y": $hy,
                "nominal_size": ${builtins.toString nominalSize}
              }
            ]
            JSONEOF
            ${
              if aliases != [ ] then
                builtins.concatStringsSep "\n" (map (a: "ln -sf ${def.name} cursors_scalable/${a}") aliases)
              else
                ""
            }
          ''
        ) cursorDefs
      )}
    '';

in
{
  inherit
    indexTheme
    xcursorBuild
    hyprBuild
    kdeSvgBuild
    ;
}
