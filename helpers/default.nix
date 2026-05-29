{ lib, pkgs, ... }:

let
  strings = import ./strings.nix { inherit lib; };
  lists = import ./lists.nix { inherit lib; };
  options = import ./options.nix { inherit lib; };
  webservices-helpers = import ./webservices-helpers.nix { inherit lib; };
  modules-info = import ./modules-info.nix { inherit lib; };
  perms = import ./perms.nix { inherit lib; };
  deepTrace = import ./deepTrace.nix { inherit lib; };
in
strings // perms // deepTrace // lists // options // webservices-helpers // modules-info
