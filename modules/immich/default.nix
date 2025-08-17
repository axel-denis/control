let
  pkgs = import <nixpkgs> {};
  result = pkgs.lib.evalModules {
    modules = [
      ./immich.nix
    ];
  };
in
result.config

# helper to test with nix-instantiate --eval