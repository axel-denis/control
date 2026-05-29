{ lib }:

let
  helpers = {
    lists = import ./lists.nix { inherit lib; };
    strings = import ./strings.nix { inherit lib; };
  };
in
with lib;
let
  /*
    TYPES

    MODULE: [{name: string, value: {...}}]
    OWNED_PATH: {owner: string; path: string}
    MULTIPLE_OWNED_PATH {owner: string; owners: [string]; path: string}
    GROUP_OWNED_PATH {owner: string; groupname: string; path: string} (groupname: owners sorted + dedup + concat. ex: ImmichJellyfin)
  */

  # [ MODULE ] -> [ OWNED_PATH ]
  # makes a list of all the paths from every given module
  GetPathsFromModules =
    let
      # MODULE -> [ OWNED_PATH ]
      # gets the paths of this module
      extractModulePath =
        module:
        map (p: {
          owner = module.name;
          path = p;
        }) module.value._meta.paths;

    in
    modules: concatMap (m: extractModulePath m) modules;

  # [ OWNED_PATH ] -> [ MULTIPLE_OWNED_PATH ]
  # computePathOwners for each path
  ComputeAllPathsOwners =
    let
      # path, path  -> bool
      doesPathOverlapWith = path1: path2: (hasPrefix path1 path2 || hasPrefix path2 path1);

      # OWNED_PATH, [ OWNED_PATHS ] -> MULTIPLE_OWNED_PATH
      # for each path, makes a list of owners (determined by a simple overlap function for now)
      computePathOwners = path: paths: {
        owner = path.owner;
        owners = helpers.lists.dedup (
          map (p: p.owner) (filter (p: doesPathOverlapWith path.path p.path) paths)
        );
        path = path.path;
      };

    in
    paths: flatten (map (p: computePathOwners p paths) paths);

  # [MULTIPLE_OWNED_PATH] -> [GROUP_OWNED_PATH]
  # for every path, replaces the list of owners by the generated group name
  ComputeGroups =
    let
      # [string] -> [string]
      # sort owners, and concatenate them, ex: ImmichJellyfin
      ownersToGroupName =
        owners: concatStrings (map (a: helpers.strings.toName (toLower a)) (sort (a: b: a < b) owners));
    in

    paths:
    map (p: {
      owner = p.owner;
      groupname = ownersToGroupName p.owners;
      path = p.path;
    }) paths;

in
{
  # [ MODULE ] -> [ GROUP_OWNED_PATH ]
  ComputePathPerms = modules: ComputeGroups (ComputeAllPathsOwners (GetPathsFromModules modules));

  # [ GROUP_OWNED_PATH ] -> [string]
  # generates the permissions for systemd.tmpfiles.rules
  ComputeTmpfilesRules =
    paths:
    flatten (
      map (p: [
        "d ${p.path} 0700 ${helpers.strings.toUsername p.owner} ${p.groupname} - -"
        "Z ${p.path} 0700 ${helpers.strings.toUsername p.owner} ${p.groupname} - -"
      ]) paths
    );
}
