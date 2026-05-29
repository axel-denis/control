{
  config,
  helpers,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.control;

  # -> [ MODULE ]
  # list of all the affected modules
  MODULES = helpers.controlModulesList cfg;

  # TODO - still need to assign groups to users
in
{
  config = {
    warnings = map (wp: (lists.flatten (webservicePathsToPerms wp.name wp.paths))) webservicesPaths;
    systemd.tmpfiles.rules = mkIf true (
      with helpers; ComputePerms (ComputeGroups (ComputeAllPathsOwners (GetPathsFromModules MODULES)))
    );
  };
}
