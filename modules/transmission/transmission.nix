{ config, helpers, lib, ... }:

with lib;

let cfg = config.myhomeserver.transmission;
in {
  options.myhomeserver.transmission = {
    enable = mkEnableOption "Enable Transmission";

    version = mkOption {
      type = types.string;
      default = "latest";
      defaultText = "latest";
      description = "Version name to use for Transmission images";
    };

    rootPath = mkOption {
      type = types.path;
      description = "Root path for Transmission data (required)";
    };

    pathOverride = {
      download = helpers.mkInheritedPathOption {
        parentName = "rootPath";
        parent = cfg.rootPath;
        defaultSubpath = "downloads";
        description = "Path for Transmission downloads.";
      };

      config = helpers.mkInheritedPathOption {
        parentName = "rootPath";
        parent = cfg.rootPath;
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
      default = 9091;
      defaultText = "9091";
      description = "Port to use for Transmission";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;
    virtualisation.oci-containers.backend = "docker";

    virtualisation.oci-containers.containers.transmission = {
      image = "haugene/transmission-openvpn:${cfg.version}";
      extraOptions = [ "--cap-add=NET_ADMIN" ];

      volumes = [
        "${cfg.pathOverride.download}:/data"
        "${cfg.pathOverride.config}:/config"
      ];

      environmentFiles = [ cfg.environmentFile ];
      ports = [ "${toString cfg.port}:9091" ];
    };
  };
}
