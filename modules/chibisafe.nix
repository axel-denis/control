{
  config,
  helpers,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.control.chibisafe;
  name = "chibisafe";
  Caddyfile = pkgs.writeText "Caddyfile" ''
    {$BASE_URL} {
      route {
        file_server * {
            root /app/uploads
            pass_thru
        }

        @api path /api/*
        reverse_proxy @api http://chibisafe_server:8000 {
            header_up Host {http.reverse_proxy.upstream.hostport}
            header_up X-Real-IP {http.request.header.X-Real-IP}
        }

        @docs path /docs*
        reverse_proxy @docs http://chibisafe_server:8000 {
            header_up Host {http.reverse_proxy.upstream.hostport}
            header_up X-Real-IP {http.request.header.X-Real-IP}
        }

        reverse_proxy http://chibisafe:8001 {
            header_up Host {http.reverse_proxy.upstream.hostport}
            header_up X-Real-IP {http.request.header.X-Real-IP}
        }
      }
    }
  '';
in
{
  options.control.chibisafe =
    (helpers.webServiceDefaults {
      name = helpers.toName name;
      version = "latest";
      subdomain = name;
      port = 10004;
    })
    // {
      paths = {
        default = helpers.mkInheritedPathOption {
          parentName = "home server global default path";
          parent = config.control.defaultPath;
          defaultSubpath = name;
          description = "Root path for chibisafe media and appdata";
        };

        database = helpers.mkInheritedPathOption {
          parentName = "paths.default";
          parent = cfg.paths.default;
          defaultSubpath = "database";
          description = "Path for chibisafe database.";
        };

        uploads = helpers.mkInheritedPathOption {
          parentName = "paths.default";
          parent = cfg.paths.default;
          defaultSubpath = "uploads";
          description = "Path for chibisafe uploads.";
        };

        logs = helpers.mkInheritedPathOption {
          parentName = "paths.default";
          parent = cfg.paths.default;
          defaultSubpath = "logs";
          description = "Path for chibisafe logs.";
        };
      };
    };

  config =
    mkIf cfg.enable {
      virtualisation.oci-containers.containers = {
        ${name} = {
          podman.user = helpers.toUsername name;
          image = "chibisafe/chibisafe:${cfg.version}";
          environment = {
            BASE_API_URL = "http://chibisafe_server:8000";
          };
          extraOptions = [
            (mkIf config.control.updateContainers "--pull=always")
          ];
        };

        "${name}_server" = {
          podman.user = helpers.toUsername name;
          image = "chibisafe/chibisafe-server:${cfg.version}";
          volumes = [
            "${cfg.paths.database}:/app/database:rw"
            "${cfg.paths.uploads}:/app/uploads:rw"
            "${cfg.paths.logs}:/app/logs:rw"
          ];
          extraOptions = [
            (mkIf config.control.updateContainers "--pull=always")
          ];
        };

        "${name}_caddy" = {
          podman.user = helpers.toUsername name;
          image = "caddy:2-alpine";
          ports = helpers.webServicePort config cfg 80;
          environment = {
            BASE_URL = ":80";
          };
          volumes = [
            "${cfg.paths.uploads}:/app/uploads:ro"
            "${Caddyfile}:/etc/caddy/Caddyfile:ro"
          ];
          extraOptions = [
            (mkIf config.control.updateContainers "--pull=always")
          ];
        };
      };
    }
    // helpers.controlUser name;
}
