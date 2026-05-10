# tests.nix
let
  pkgs = import <nixpkgs> { };
  helpers = import ./helpers/default.nix { inherit (pkgs) lib; };
in
{
  testUpper = helpers.toName "coucou" == "Coucou";
  testEmpty = helpers.toName "" == "";
  testAlreadyUpper = helpers.toName "Coucou" == "Coucou";
}
