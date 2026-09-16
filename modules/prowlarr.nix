{
  config,
  helpers,
  lib,
  ...
}:

with lib;

let
  cfg = config.control.prowlarr;
in
{
  options.control.prowlarr =
    (helpers.webServiceDefaults {
      name = "Prowlarr";
      version = "latest";
      subdomain = "prowlarr";
      port = 10015;
    })
    // {
      environmentFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = "Env file for vpn config";
      };

      wireguardConfigFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        example = "/secrets/windscribe-wg0.conf";
        description = ''
          Path to your WireGuard (.conf)
          Mounted on the container to /config/wireguard/wg0.conf
        '';
      };

      paths = {
        default = helpers.mkInheritedPathOption {
          parentName = "home server global default path";
          parent = config.control.defaultPath;
          defaultSubpath = "prowlarr";
          description = "Root path for Prowlarr data";
        };

        config = helpers.mkInheritedPathOption {
          parentName = "paths.default";
          parent = cfg.paths.default;
          defaultSubpath = "config";
          description = "Prowlarr appdata";
        };
      };
    };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;
    virtualisation.oci-containers.backend = "docker";

    # Creating directory with the user id asked by the container
    systemd.tmpfiles.rules = [ "d ${cfg.paths.default} 0755 1000 1000" ];
    virtualisation.oci-containers.containers.prowlarr = {
      image = "ghcr.io/hotio/prowlarr:${cfg.version}";
      ports = helpers.webServicePort config cfg 9696;

      extraOptions = [
        (mkIf config.control.updateContainers "--pull=always")
        "--device=/dev/net/tun:/dev/net/tun"
      ];

      capabilities = {
        NET_ADMIN = true;
      };

      environment = {
        PUID = "1000";
        PGID = "1000";
        UMASK = "002";
        TZ = "Europe/Paris";
        WEBUI_PORTS = "9696/tcp";
      };

      environmentFiles = [ cfg.environmentFile ];

      volumes = [
        "${cfg.paths.config}:/config"
      ]
      ++ optional (cfg.wireguardConfigFile != null)
        "${toString cfg.wireguardConfigFile}:/config/wireguard/wg0.conf:ro";
    };
  };
}
