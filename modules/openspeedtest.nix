{ config, helpers, lib, ... }:

with lib;
let cfg = config.homeserver.openspeedtest;
in {
  options.homeserver.openspeedtest = {
    enable = mkEnableOption "Enable OpenSpeedTest";

    version = mkOption {
      type = types.str;
      default = "latest";
      defaultText = "latest";
      description = "Version name to use for openspeedtest images";
    };

    port = mkOption {
      type = types.int;
      default = 10006;
      defaultText = "10006";
      description = "Port to use for OpenSpeedTest";
    };

    forceLan = mkEnableOption ''
        Force LAN access, ignoring router configuration.
        You will be able to access this container on <lan_ip>:${toString cfg.port} regardless of your router configuration.
    '';

    basicAuth = mkOption {
      type = with types; attrsOf str;
      default = { };
      description = ''
        If set, enable Nginx basic authentication for this service.
        The value should be an attribute set of username-password pairs, e.g.
        { user1 = "password1"; user2 = "password2"; }
        Keep in mind that basic authentication works for web pages but can break dependant services (e.g. mobile apps).
      '';
    };

    # ANCHOR - simple ctrl-shift-f insert for all webservices

    subdomain = mkOption {
      type = types.str;
      default = "openspeedtest";
      defaultText = "openspeedtest";
      description = "Subdomain to use for OpenSpeedTest";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;
    virtualisation.oci-containers.backend = "docker";

    virtualisation.oci-containers.containers = {
      openspeedtest = {
        image = "openspeedtest/${cfg.version}";
        ports = [ "${if (config.homeserver.routing.lan || cfg.forceLan) then "" else "127.0.0.1:"}${toString cfg.port}:3000" ];
      };
    };
  };
}

