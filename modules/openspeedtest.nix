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

    forceLan = mkOption {
      type = types.bool;
      default = false;
      description = "Force LAN access, ignoring router configuration.";
    };

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

