{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    purr.url = "github:nixcafe/purr";
    git-hooks = {
      url = "https://flakehub.com/f/cachix/git-hooks.nix/0.1.*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.purr.lib.mkFlake {
      inherit inputs;
      src = ./.;
      namespace = "nhmeow";
      outputsBuilder = { pkgs, ... }: {
        formatter = pkgs.nixfmt;
      };
    };
}
