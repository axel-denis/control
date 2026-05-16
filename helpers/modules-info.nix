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

  modulesList = conf: attrsets.mapAttrsToList (name: value: value) conf;
}
