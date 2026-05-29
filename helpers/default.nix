{ lib, pkgs, ... }:

let
  strings = import ./strings.nix { inherit lib; };
  lists = import ./lists.nix { inherit lib; };
  options = import ./options.nix { inherit lib; };
  webservices-helpers = import ./webservices-helpers.nix { inherit lib; };
  modules-info = import ./modules-info.nix { inherit lib; };
in
strings // lists // options // webservices-helpers // modules-info
