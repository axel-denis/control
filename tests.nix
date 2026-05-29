let
  pkgs = import <nixpkgs> { };
  lib = pkgs.lib;
  helpers = import ./helpers/default.nix { inherit pkgs lib; };

  ### paths tests inputs and results

  MODULES_INPUTS = [
    {
      name = "Jellyfin";
      value._meta.paths = [
        "/jellyfin/media"
        "/transmission/completed"
      ];
    }
    {
      name = "Transmission";
      value._meta.paths = [
        "/transmission"
      ];
    }
    {
      name = "Immich";
      value._meta.paths = [
        "/immich"
      ];
    }
  ];
  GROUP_OWNED_PATHS_RESULTS = lib.sort (a: b: a.path > b.path) [
    {
      owner = "Jellyfin";
      groupname = "Jellyfin";
      path = "/jellyfin/media";
    }
    {
      owner = "Jellyfin";
      groupname = "JellyfinTransmission";
      path = "/transmission/completed";
    }
    {
      owner = "Transmission";
      groupname = "JellyfinTransmission";
      path = "/transmission";
    }
    {
      owner = "Immich";
      groupname = "Immich";
      path = "/immich";
    }
  ];

  ###
in
lib.runTests {
  testUpper = {
    expr = helpers.toName "coucou";
    expected = "Coucou";
  };
  testEmpty = {
    expr = helpers.toName "";
    expected = "";
  };
  testAlreadyUpper = {
    expr = helpers.toName "Coucou";
    expected = "Coucou";
  };

  testPathsGroups = with pkgs; {
    expr = lib.sort (a: b: a.path > b.path) (with helpers; ComputePathPerms MODULES_INPUTS);
    expected = GROUP_OWNED_PATHS_RESULTS;
  };

  testUsersGroups = with pkgs; {
    expr = helpers.GetGroupsForUser "Jellyfin" (helpers.ComputePathPerms MODULES_INPUTS);
    expected = [
      "Jellyfin"
      "JellyfinTransmission"
    ];
  };
}
