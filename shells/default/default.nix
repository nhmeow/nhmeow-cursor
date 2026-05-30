{
  inputs,
  pkgs,
  mkShell,
  system,
  ...
}:
mkShell {
  packages = with pkgs; [
    nixfmt
    deadnix
    statix
    xcursorgen
    librsvg
    hyprcursor
  ];

  inherit (inputs.self.checks.${system}.pre-commit-check) shellHook;
  buildInputs = inputs.self.checks.${system}.pre-commit-check.enabledPackages;
}
