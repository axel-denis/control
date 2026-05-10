# repl.nix
let
  pkgs = import <nixpkgs> { };
in
{
  inherit pkgs;
  helpers = import ./helpers/default.nix { inherit (pkgs) lib; };
}
