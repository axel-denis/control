let
  pkgs = import <nixpkgs> { };
  lib = pkgs.lib;
  helpers = import ./helpers/default.nix { inherit pkgs lib; };

  ### paths tests inputs and results

  MODULES_INPUTS = [
    {
      name = "jellyfin";
      value._meta.paths = [
        "/jellyfin/media"
        "/transmission/completed"
      ];
      value._meta.name = "jellyfin";
    }
    {
      name = "transmission";
      value._meta.paths = [
        "/transmission"
      ];
      value._meta.name = "transmission";
    }
    {
      name = "immich";
      value._meta.paths = [
        "/immich"
      ];
      value._meta.name = "immich";
    }
  ];
  GROUP_OWNED_PATHS_RESULTS = lib.sort (a: b: a.path > b.path) [
    {
      owner = "jellyfin";
      groupname = "Jellyfin";
      path = "/jellyfin/media";
    }
    {
      owner = "jellyfin";
      groupname = "JellyfinTransmission";
      path = "/transmission/completed";
    }
    {
      owner = "transmission";
      groupname = "JellyfinTransmission";
      path = "/transmission";
    }
    {
      owner = "immich";
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

  testGetUsersForGroup = with pkgs; {
    expr = helpers.GetUsersForGroup "JellyfinTransmission" (helpers.ComputePathPerms MODULES_INPUTS);
    expected = [
      "jellyfin"
      "transmission"
    ];
  };

  testModulesNames = with pkgs; {
    expr = helpers.controlModulesNamesList MODULES_INPUTS;
    expected = [
      "jellyfin"
      "transmission"
      "immich"
    ];
  };
}
