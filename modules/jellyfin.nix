{ config, helpers, lib, ... }:

with lib;
let cfg = config.homeserver.jellyfin;
in {
  options.homeserver.jellyfin = {
    enable = mkEnableOption "Enable Jellyfin";

    version = mkOption {
      type = types.str;
      default = "latest";
      defaultText = "latest";
      description = "Version name to use for Jellyfin images";
    };

    subdomain = mkOption {
      type = types.str;
      default = "jellyfin";
      defaultText = "jellyfin";
      description = "Subdomain to use for Jellyfin";
    };

    port = mkOption {
      type = types.int;
      default = 10002;
      defaultText = "10002";
      description = "Port to use for Jellyfin";
    };

    forceLan = mkEnableOption ''
        Force LAN access, ignoring router configuration.
        You will be able to access this container on <lan_ip>:${toString cfg.port} regardless of your router configuration.
    '';

    paths = {
      default = helpers.mkInheritedPathOption {
        parentName = "home server global default path";
        parent = config.homeserver.defaultPath;
        defaultSubpath = "jellyfin";
        description = "Root path for Jellyfin media and appdata";
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
        ports = [ "${if (config.homeserver.routing.lan || cfg.forceLan) then "" else "127.0.0.1:"}${toString cfg.port}:8096" ];
        volumes = [
          #"${jellyfinRoot}/media:/media"
          "${cfg.paths.media}:/media"
          "${cfg.paths.config}:/config"
        ];
      };
    };
  };
}

