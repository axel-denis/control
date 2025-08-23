{ config, helpers, lib, ... }:

with lib;
let cfg = config.homeserver.openspeedtest;
in {
  options.homeserver.openspeedtest = {
    enable = mkEnableOption "Enable OpenSpeedTest";

    version = mkOption {
      type = types.string;
      default = "latest";
      defaultText = "latest";
      description = "Version name to use for openspeedtest images";
    };

    httpPort = mkOption {
      type = types.int;
      default = 3000;
      defaultText = "3000";
      description = "Port to use for OpenSpeedTest";
    };

    httpsPort = mkOption {
      type = types.int;
      default = 3001;
      defaultText = "3001";
      description = "Port to use for OpenSpeedTest";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;
    virtualisation.oci-containers.backend = "docker";

    virtualisation.oci-containers.containers = {
      openspeedtest = {
        image = "openspeedtest/${cfg.version}";
        ports = [ "${toString cfg.httpPort}:3000" "${cfg.httpsPort}:3001" ];
      };
    };
  };
}

