{ config, helpers, lib, ... }:

with lib;

let cfg = config.homeserver.transmission;
in {
  options.homeserver.transmission = {
    enable = mkEnableOption "Enable Transmission";

    version = mkOption {
      type = types.str;
      default = "latest";
      defaultText = "latest";
      description = "Version name to use for Transmission images";
    };

    subdomain = mkOption {
      type = types.str;
      default = "transmission";
      defaultText = "transmission";
      description = "Subdomain to use for Transmission";
    };

    paths = {
      default = helpers.mkInheritedPathOption {
        parentName = "home server global default path";
        parent = config.homeserver.defaultPath;
        defaultSubpath = "transmission";
        description = "Root path for Transmission data";
      };

      download = helpers.mkInheritedPathOption {
        parentName = "paths.default";
        parent = cfg.paths.default;
        defaultSubpath = "downloads";
        description = "Path for Transmission downloads.";
      };

      config = helpers.mkInheritedPathOption {
        parentName = "paths.default";
        parent = cfg.paths.default;
        defaultSubpath = "config";
        description = "Path for Transmission config.";
      };
    };

    environmentFile = mkOption {
      type = types.path;
      description = "Transmission configuration. See official documentation";
    };

    port = mkOption {
      type = types.int;
      default = 10003;
      defaultText = "10003";
      description = "Port to use for Transmission";
    };

    forceLan = mkEnableOption ''
        Force LAN access, ignoring router configuration.
        You will be able to access this container on <lan_ip>:${toString cfg.port} regardless of your router configuration.
    '';
  };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;
    virtualisation.oci-containers.backend = "docker";

    virtualisation.oci-containers.containers.transmission = {
      image = "haugene/transmission-openvpn:${cfg.version}";
      extraOptions = [ "--cap-add=NET_ADMIN" ];

      volumes = [
        "${cfg.paths.download}:/data"
        "${cfg.paths.config}:/config"
      ];

      environmentFiles = [ cfg.environmentFile ];
      ports = [ "${if (config.homeserver.routing.lan || cfg.forceLan) then "" else "127.0.0.1:"}${toString cfg.port}:9091" ];
    };
  };
}
