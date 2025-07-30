{ config, lib, ... }:

with lib;

let cfg = config.myhomeserver.jellyfin;
in {
  options.myhomeserver.jellyfin = {
    enable = mkEnableOption "Enable Jellyfin";

    version = mkOption {
      type = types.string;
      default = "release";
      defaultText = "release";
      description = "Version name to use for Jellyfin images";
    };

    rootPath = mkOption {
      type = types.path;
      description = "Root path for Jellyfin media and appdata (required)";
    };

    port = mkOption {
      type = types.int;
      default = 8096;
      defaultText = "8096";
      description = "Port to use for Immich";
    };

    pathOverride = {
      media = mkInheritedPathOption {
        parentName = "rootPath";
        parent = cfg.rootPath;
        defaultSubpath = "media";
        description = "Path for Jellyfin media (movies).";
      };

      config = mkInheritedPathOption {
        parentName = "rootPath";
        parent = cfg.rootPath;
        defaultSubpath = "config";
        description = "Path for Jellyfin appdata (config).";
      };
    };
  };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;
    virtualisation.oci-containers.containers = {
      jellyfin = {
        image = "jellyfin/jellyfin:latest";
        ports = [ "8096:${cfg.port}" ];
        volumes = [
          #"${jellyfinRoot}/media:/media"
          "/mnt/films/:/media"
          "${jellyfinRoot}/config:/config"
        ];
      };
    };
  };
}

