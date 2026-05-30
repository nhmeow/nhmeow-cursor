# nhmeow-cursor

Mouse cursor theme for X11 & Wayland, built with Nix.

Packs both **XCursor** (X11) and **Hyprcursor** (Hyprland) from a single set of SVG sources.

## Structure

```
.
├── flake.nix
├── checks/pre-commit-check/default.nix
├── shells/default/default.nix
├── packages/nhmeow-cursor/
│   ├── default.nix        # derivation
│   ├── build.nix          # build helpers (xcursorgen + hyprcursor-util)
│   ├── cursors.nix        # cursor definitions (SVG -> names + hotspots)
│   └── src/               # SVG cursor images
└── statix.toml
```

## Usage

```sh
# Build
nix build .#nhmeow-cursor

# Try (quick test)
ln -sf $(readlink -f result/share/icons/nhmeow-cursor) ~/.local/share/icons/nhmeow-cursor
gsettings set org.gnome.desktop.interface cursor-theme "nhmeow-cursor"
```

## Dev

```sh
direnv allow
```

Shell provides `xcursorgen`, `rsvg-convert`, `hyprcursor-util`.

## Adding cursors

1. Drop an SVG in `packages/nhmeow-cursor/src/` named `{name}_312x312.svg`
2. Add an entry to `cursors.nix`:

```nix
{
  svg = "mycursor_312x312.svg";
  name = "mycursor";
  hx = 0.08;   # hotspot x (0-1)
  hy = 0.05;   # hotspot y (0-1)
  overrides = [ "mycursor" "alt_name" ];
}
```
