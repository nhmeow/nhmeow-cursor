# nhmeow-cursor

Mouse cursor theme built with Nix. One source → three formats.

| Format      | Directory             | Targets               |
|-------------|-----------------------|-----------------------|
| XCursor     | `cursors/`            | X11, all DE, Wayland fallback |
| KDE SVG     | `cursors_scalable/`   | Plasma 6.2+ Wayland   |
| Hyprcursor  | `hyprcursors/`        | Hyprland              |

## Structure

```
packages/nhmeow-cursor/
├── default.nix        # derivation
├── build.nix          # build helpers (xcursorgen + hyprcursor-util + KDE SVG)
├── cursors.nix        # cursor definitions (SVG -> names + hotspots)
└── src/               # SVG cursor images
```

## Usage

```sh
nix build .#nhmeow-cursor
result/share/icons/nhmeow-cursor/
├── cursors/              # XCursor (16 files + 42 aliases)
├── cursors_scalable/     # KDE SVG (16 dirs + 42 alias symlinks)
├── hyprcursors/          # Hyprcursor (16 .hlc)
├── index.theme
└── manifest.hl
```

## Adding cursors

1. Add SVG to `src/`
2. Add entry to `cursors.nix`:

```nix
{
  svg = "mycursor_312x312.svg";
  name = "mycursor";
  hx = 0.08;   # hotspot x (0-1 fraction)
  hy = 0.05;   # hotspot y (0-1 fraction)
  overrides = [ "mycursor" "alt_name" ];
}
```
