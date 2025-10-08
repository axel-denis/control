{
  config,
  helpers,
  lib,
  ...
}:

with lib;
let
  cfg = config.control.jellyfin;
in
{
  options.control.jellyfin =
    (helpers.webServiceDefaults {
      name = "Jellyfin";
      version = "latest";
      subdomain = "jellyfin";
      port = 10002;
    })
    // {
      paths = {
        default = helpers.mkInheritedPathOption {
          parentName = "home server global default path";
          parent = config.control.defaultPath;
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
        ports = helpers.webServicePort config cfg 8096;
        volumes = [
          "${cfg.paths.media}:/media"
          "${cfg.paths.config}:/config"
        ];
      };
    };
  };
}
