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

  # {name, value}
  webservices =
    (filter helpers.isEnabledWebModule (helpers.modulesList cfg));

  modulesList = conf: attrsets.mapAttrsToList (name: value: trace name value) conf;

  # {name, [paths]}
  webservicesPaths = map (s: {
    name = s.name;
    paths = (attrsets.mapAttrsToList (n: v: v) s.paths);
  }) webservices;

  # path, [paths]  -> bool
  doesPathOverlapWith =
    path: paths: length (filter (p: (hasPrefix p path || hasPrefix path p)) paths) > 0;

  # [paths], [otherpaths]  -> bool
  doesPathsOverlapWith =
    paths: otherpaths: length (filter (p: doesPathOverlapWith p otherpaths) paths) > 0;

  # name -> all other webservicesPaths
  otherServicesThan = name: filter (wp: wp.name != name) webservicesPaths;

  doesServiceOverlapWithOtherService =
    service1: service2: doesPathsOverlapWith service1.paths service2.paths;

  # service -> [names]
  serviceOverlaps =
    service:
    fold (
      acc: v: (acc ++ (if (doesServiceOverlapWithOtherService service v) then [ v.name ] else [ ]))
    ) [ ] (otherServicesThan name);

  # [members: [members names]]
  overlapGroups = map (e: e) webservicesPaths;

  #[strings]
  webservicePathsToPerms =
    name: paths:
    map (p: [
      "d ${p} 0700 ${helpers.toUsername name} ${groupname} - -"
      "Z ${p} 0700 ${helpers.toUsername name} ${groupname} - -"
    ]) paths;
in
{
  config = {
    warnings = map (wp: (lists.flatten (webservicePathsToPerms wp.name wp.paths))) webservicesPaths;
    systemd.tmpfiles.rules = mkIf true (
      let o = map (wp: (lists.flatten (webservicePathsToPerms wp.name wp.paths))) webservicesPaths; in trace o o
    );
  };
}
