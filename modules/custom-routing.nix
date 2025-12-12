{ config, helpers, lib, pkgs, ... }:

with lib;
let cfg = config.control.custom-routing;
in {
  options.control.custom-routing = {
    entries = mkOption {
      type = types.listOf {
        subdomain = string;
        port = number; # http only, https is managed by nginx
        basicAuth = bool;
      };
      default = [ ];
      description = "Custom routing entries for non-control modules";
    };
  };

  # TODO - check that no port or subdomain overlap other modules
}
