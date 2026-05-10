{
  config,
  helpers,
  lib,
  ...
}:

with lib;

let
  cfg = config.control.transmission;
  name = "transmission";
in
{
  options.control.transmission =
    (helpers.webServiceDefaults {
      name = helpers.toName name;
      version = "latest";
      subdomain = name;
      port = 10003;
    })
    // {
      environmentFile = mkOption {
        type = types.path;
        description = "Transmission configuration. See official documentation";
      };

      paths = {
        default = helpers.mkInheritedPathOption {
          parentName = "home server global default path";
          parent = config.control.defaultPath;
          defaultSubpath = name;
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
    };

  config = mkIf cfg.enable {

    virtualisation.oci-containers.containers.${name} = {
      podman.user = helpers.toUsername name;
      image = "haugene/transmission-openvpn:${cfg.version}";
      extraOptions = [
        "--cap-add=NET_ADMIN"
        (mkIf config.control.updateContainers "--pull=always")
      ];

      volumes = [
        "${cfg.paths.download}:/data"
        "${cfg.paths.config}:/config"
      ];

      environmentFiles = [ cfg.environmentFile ];
      ports = helpers.webServicePort config cfg 9091;
    };
  };
}

/*
  example env file for transmission-openvpn:
  OPENVPN_PROVIDER=PIA
  OPENVPN_CONFIG=france
  OPENVPN_USERNAME=user
  OPENVPN_PASSWORD=pass
  LOCAL_NETWORK=192.168.0.0/16 # or 127.0.0.0/8 ? 0.0.0.0/0 ?
*/
