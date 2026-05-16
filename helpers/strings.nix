{ lib }:

with lib;
rec {
  toName = name: (toUpper (substring 0 1 name)) + (substring 1 (-1) name); # jellyfin -> Jellyfin
  toUsername = name: "control" + (toName name); # jellyfin -> controlJellyfin
  toGroupname = name: "control" + (toName name) + "Group"; # jellyfin -> controlJellyfinGroup
}
