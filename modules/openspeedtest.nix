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

    # httpPort = mkOption {
    #   type = types.int;
    #   default = 3000;
    #   defaultText = "3000";
    #   description = "Port to use for OpenSpeedTest";
    # };

    port = mkOption {
      type = types.int;
      default = 10006;
      defaultText = "10006";
      description = "Port to use for OpenSpeedTest";
    };

    subdomain = mkOption {
      type = types.string;
      default = "speedtest";
      defaultText = "speedtest";
      description = "Subdomain to use for OpenSpeedTest";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;
    virtualisation.oci-containers.backend = "docker";

    virtualisation.oci-containers.containers = {
      openspeedtest = {
        image = "openspeedtest/${cfg.version}";
        ports = [ "${optionals (!config.homeserver.routing.lan) "127.0.0.1:"}${toString cfg.port}:3000" ];
      };
    };
  };
}

