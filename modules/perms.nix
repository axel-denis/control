{
  config,
  helpers,
  lib,
  pkgs,
  ...
}:

with lib;

/*
  TYPES

  MODULE: [{name: string, value: {...}}]
  OWNED_PATH: {owner: string; path: string}
  MULTIPLE_OWNED_PATH {owner: string; owners: [string]; path: string}
  GROUP_OWNED_PATH {owner: string; groupname: string; path: string} (groupname: owners sorted + dedup + concat. ex: ImmichJellyfin)
*/

let
  cfg = config.control;

  # -> [ MODULE ]
  # list of all the affected modules
  MODULES = helpers.controlModulesList cfg;

  # MODULE -> [ OWNED_PATH ]
  # gets the paths of this module
  extractModulePath =
    module:
    map (p: {
      owner = module.name;
      path = p;
    }) module.value._meta.paths;

  # [ MODULE ] -> [ OWNED_PATH ]
  # makes a list of all the paths from every given module
  GetPathsFromModules = modules: concatMap (m: extractModulePath m) modules;

  # path, path  -> bool
  doesPathOverlapWith = path1: path2: (hasPrefix path1 path2 || hasPrefix path2 path1);

  # OWNED_PATH, [ OWNED_PATHS ] -> MULTIPLE_OWNED_PATH
  # for each path, makes a list of owners (determined by a simple overlap function for now)
  computePathOwners = path: paths: {
    owner = p.owner;
    owners = helpers.dedup (map (p: p.owner) (filter (p: doesPathOverlapWith path.path p.path) paths));
    path = path.path;
  };

  # [ OWNED_PATH ] -> [ MULTIPLE_OWNED_PATH ]
  # computePathOwners for each path
  ComputeAllPathsOwners = paths: flatten (map (p: computePathOwners p paths) paths);

  # [string] -> [string]
  # sort owners, and concatenate them, ex: ImmichJellyfin
  ownersToGroupName = owners: map (a: helpers.toName (toLower a)) (sort (a: b: a < b) owners);

  # [MULTIPLE_OWNED_PATH] -> [GROUP_OWNED_PATH]
  # for every path, replaces the list of owners by the generated group name
  ComputeGroups =
    paths:
    map (p: {
      owner = p.owner;
      groupname = ownersToGroupName p.owners;
      path = p.path;
    }) paths;

  # [ GROUP_OWNED_PATH ] -> [string]
  # generates the permissions for systemd.tmpfiles.rules
  ComputePerms =
    paths:
    flatten (
      map (p: [
        "d ${p.path} 0700 ${helpers.toUsername p.owner} ${p.groupname} - -"
        "Z ${p.path} 0700 ${helpers.toUsername p.owner} ${p.groupname} - -"
      ]) paths
    );
in
{
  config = {
    warnings = map (wp: (lists.flatten (webservicePathsToPerms wp.name wp.paths))) webservicesPaths;
    systemd.tmpfiles.rules = mkIf true (
      ComputePerms (ComputeGroups (ComputeAllPathsOwners (GetPathsFromModules MODULES)))
    );
  };
}
