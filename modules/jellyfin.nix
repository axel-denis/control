{ config, helpers, lib, ... }:

with lib;
let cfg = config.homeserver.jellyfin;
in {
  options.homeserver.jellyfin = {
    enable = mkEnableOption "Enable Jellyfin";

    version = mkOption {
      type = types.string;
      default = "latest";
      defaultText = "latest";
      description = "Version name to use for Jellyfin images";
    };

    port = mkOption {
      type = types.int;
      default = 10002;
      defaultText = "10002";
      description = "Port to use for Jellyfin";
    };

    paths = {
      default = mkOption {
        type = types.path;
        description = "Root path for Jellyfin media and appdata (required)";
      };

      media = helpers.mkInheritedPathOption {
        parentName = "paths.default";
        parent = cfg.paths.default;
        defaultSubpath = "media";
        description = "Path for Jellyfin media (movies).";
      };

      config = helpers.mkInheritedPathOption {
        parentName = "paths.default";
        parent = cfg.paths.default;
        defaultSubpath = "config";
        description = "Path for Jellyfin appdata (config).";
      };
    };
  };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;
    virtualisation.oci-containers.backend = "docker";

    virtualisation.oci-containers.containers = {
      jellyfin = {
        image = "jellyfin/jellyfin:${cfg.version}";
        ports = [ "${toString cfg.port}:8096" ];
        volumes = [
          #"${jellyfinRoot}/media:/media"
          "${cfg.paths.media}:/media"
          "${cfg.paths.config}:/config"
        ];
      };
    };
  };
}

