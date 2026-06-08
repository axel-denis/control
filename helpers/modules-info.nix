{ lib }:

with lib;
let
  lists = import ./lists.nix { inherit lib; };
in
rec {
  isEnabledWebModule =
    module:
    module ? enable
    && module.enable
    && module ? subdomain
    && module ? port
    && module ? lanOnly
    && !module.lanOnly;
  # todo - change above condition with
  /*
      (module._meta.isControlModule or false)
      && (module.enable or false)
      && !(module.lanOnly or false);
  */

  # deprecated
  modulesList = conf: attrsets.mapAttrsToList (name: value: value) conf;

  # config.control -> [{name, {...config}}]
  controlModulesList =
    conf:
    filter (m: m.value._meta.isControlModule or false) (
      attrsets.mapAttrsToList (name: value: {
        name = name;
        value = value;
      }) conf
    );

  # controlModulesList -> [ string ]
  controlModulesNamesList = moduleList: lists.dedup (map (m: m.value._meta.name) moduleList);
}
