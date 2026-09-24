{
  config,
  helpers,
  lib,
  ...
}:

with lib;

let
  cfg = config.control.radarr;
in
{
  options.control.radarr =
    (helpers.webServiceDefaults {
      name = "Radarr";
      version = "latest";
      subdomain = "radarr";
      port = 10016;
    })
    // {
      paths = {
        default = helpers.mkInheritedPathOption {
          parentName = "home server global default path";
          parent = config.control.defaultPath;
          defaultSubpath = "radarr";
          description = "Root path for Radarr data";
        };

        config = helpers.mkInheritedPathOption {
          parentName = "paths.default";
          parent = cfg.paths.default;
          defaultSubpath = "config";
          description = "Radarr appdata";
        };

        data = helpers.mkInheritedPathOption {
          parentName = "home server global default path";
          parent = config.control.defaultPath;
          defaultSubpath = "media";
          description = "Root media/data path for hardlinks and media management";
        };
      };
    };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;
    virtualisation.oci-containers.backend = "docker";

    # Creating directory with the user id asked by the container
    systemd.tmpfiles.rules = [
      "d ${cfg.paths.default} 0755 1000 1000"
      "d ${cfg.paths.config} 0755 1000 1000"
      "d ${cfg.paths.data} 0775 1000 1000"
    ];

    virtualisation.oci-containers.containers.radarr = {
      image = "ghcr.io/hotio/radarr:${cfg.version}";
      ports = helpers.webServicePort config cfg 7878;
      hostname = "radarr.internal";

      extraOptions = [ (mkIf config.control.updateContainers "--pull=always") ];

      environment = {
        PUID = "1000";
        PGID = "1000";
        UMASK = "002";
        TZ = "Europe/Paris";
        WEBUI_PORTS = "7878/tcp";
      };

      networks = [ "arr-net" ];

      volumes = [
        "${cfg.paths.config}:/config"
        "${cfg.paths.data}:/data"
      ];
    };
  };
}