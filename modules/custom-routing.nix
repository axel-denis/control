{ config, helpers, lib, pkgs, ... }:

with lib;
let cfg = config.control.custom-routing;
in {
  options.control.custom-routing = {
    entries = mkOption {
      type = with types;
        listOf (submodule {
          options = {
            subdomain = mkOption { type = str; };
            port = mkOption { type = int; };
            basicAuth = lib.mkOption {
              type = with lib.types; attrsOf str;
              default = { };
              description = ''
                If set, enable Nginx basic authentication for this service.
                The value should be an attribute set of username-password pairs, e.g.
                { user1 = "password1"; user2 = "password2"; }
                Keep in mind that basic authentication works for web pages but can break dependant services (e.g. mobile apps).
                It is also known to break ACME.
              '';
            };
          };
        });
      default = [ ];
      description = "Custom routing entries for non-control modules";
    };
  };

  # TODO - check that no port or subdomain overlap other modules
}
