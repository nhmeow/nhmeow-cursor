{
  inputs,
  pkgs,
  system,
  ...
}:
let
  git-hooks-check = inputs.git-hooks.lib.${system}.run {
    src = ../../.;
    hooks = {
      # formatter
      nixfmt.enable = true;
      deadnix.enable = true;
      statix.enable = true;
    };
  };
in
pkgs.mkShell {
  packages = with pkgs; [
    nixfmt
    deadnix
    statix
    xcursorgen
    librsvg
    hyprcursor
  ];

  inherit (git-hooks-check) shellHook;
  buildInputs = git-hooks-check.enabledPackages;
}
