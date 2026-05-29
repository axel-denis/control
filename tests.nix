let
  pkgs = import <nixpkgs> { };
  lib = pkgs.lib;
  helpers = import ./helpers/default.nix { inherit pkgs lib; };
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

  testPathsGroups =
    with pkgs;
    let
      INPUTS = [
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
      RESULTS = lib.sort (a: b: a.path > b.path) [
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
    in
    {
      expr = lib.sort (a: b: a.path > b.path) (
        with helpers; ComputeGroups (ComputeAllPathsOwners (GetPathsFromModules INPUTS))
      );
      expected = RESULTS;
    };
}
