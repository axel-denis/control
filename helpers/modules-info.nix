{ lib }:

with lib;
{
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

  # [{name, {...config}}]
  controlModulesList = conf: filter (m: m.value._meta.isControlModule or false) (attrsets.mapAttrsToList (name: value: {name = name; value = value;}) conf);
}
