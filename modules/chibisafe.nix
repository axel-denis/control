{ config, helpers, lib, pkgs, ... }:

with lib;
let
  cfg = config.homeserver.chibisafe;
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
in {
  options.homeserver.chibisafe = {
    enable = mkEnableOption "Enable chibisafe";

    version = mkOption {
      type = types.string;
      default = "latest";
      defaultText = "latest";
      description = "Version name to use for chibisafe images";
    };

    subdomain = mkOption {
      type = types.string;
      default = "chibisafe";
      defaultText = "chibisafe";
      description = "Subdomain to use for Chibisafe";
    };

    port = mkOption {
      type = types.int;
      default = 10004;
      defaultText = "10004";
      description = "Port to use for chibisafe";
    };

    paths = {
      default = mkOption {
        type = types.path;
        description = "Root path for chibisafe media and appdata (required)";
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

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;
    virtualisation.oci-containers.backend = "docker";

    virtualisation.oci-containers.containers = {
      chibisafe = {
        image = "chibisafe/chibisafe:${cfg.version}";
        environment = {
          BASE_API_URL = "http://chibisafe_server:8000";
        };
        extraOptions = [ "--network=chibinet" ];
      };

      chibisafe_server = {
        image = "chibisafe/chibisafe-server:${cfg.version}";
        volumes = [
          "${cfg.paths.database}:/app/database:rw"
          "${cfg.paths.uploads}:/app/uploads:rw"
          "${cfg.paths.logs}:/app/logs:rw"
        ];
        extraOptions = [ "--network=chibinet" ];
      };

      chibisafe_caddy = {
        image = "caddy:2-alpine";
        ports = [ "${if config.homeserver.routing.lan then "" else "127.0.0.1:"}${toString cfg.port}:80" ];
        environment = { BASE_URL = ":80"; };
        volumes = [
          "${cfg.paths.uploads}:/app/uploads:ro"
          "${Caddyfile}:/etc/caddy/Caddyfile:ro"
        ];
        extraOptions = [ "--network=chibinet" ];
      };
    };

    systemd.services = helpers.mkDockerNetworkService {
      networkName = "chibinet";
      dockerCli = "${config.virtualisation.docker.package}/bin/docker";
    };
  };
}
