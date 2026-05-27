# repl.nix
let
  pkgs = import <nixpkgs> { };
  lib = pkgs.lib;
in
{
  inherit pkgs;
  helpers = import ./helpers/default.nix { inherit pkgs lib; };
}
