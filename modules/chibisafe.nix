{ config, helpers, lib, pkgs, ... }:

with lib;
let
  cfg = config.homeserver.chibisafe;
  CaddyFile = pkgs.writeText "Caddyfile" ''
    {$BASE_URL} {
      route {
        file_server * {
            root /app/uploads
            pass_thru
        }

        @api path /api/*
        reverse_proxy @api http://chibisafe_server:${toString cfg.server-port} {
            header_up Host {http.reverse_proxy.upstream.hostport}
            header_up X-Real-IP {http.request.header.X-Real-IP}
        }

        @docs path /docs*
        reverse_proxy @docs http://chibisafe_server:${
          toString cfg.server-port
        } {
            header_up Host {http.reverse_proxy.upstream.hostport}
            header_up X-Real-IP {http.request.header.X-Real-IP}
        }

        reverse_proxy http://chibisafe:${toString cfg.port} {
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

    rootPath = mkOption {
      type = types.path;
      description = "Root path for chibisafe media and appdata (required)";
    };

    port = mkOption {
      type = types.int;
      default = 8096;
      defaultText = "8096";
      description = "Port to use for chibisafe";
    };

    server-port = helpers.mkInheritedIntOption {
      parentName = "port";
      parent = cfg.port;
      description = "Port for chibisafe server";
    };

    caddy-port = helpers.mkInheritedIntOption {
      parentName = "server-port";
      parent = cfg.server-port;
      description = "Port for chibisafe caddy";
    };

    pathOverride = {
      database = helpers.mkInheritedPathOption {
        parentName = "rootPath";
        parent = cfg.rootPath;
        defaultSubpath = "media";
        description = "Path for chibisafe media (movies).";
      };

      uploads = helpers.mkInheritedPathOption {
        parentName = "rootPath";
        parent = cfg.rootPath;
        defaultSubpath = "config";
        description = "Path for chibisafe appdata (config).";
      };

      logs = helpers.mkInheritedPathOption {
        parentName = "rootPath";
        parent = cfg.rootPath;
        defaultSubpath = "config";
        description = "Path for chibisafe appdata (config).";
      };
    };
  };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;
    virtualisation.oci-containers.backend = "docker";

    virtualisation.oci-containers.containers = {
      chibisafe = {
        image = "chibisafe/chibisafe:${cfg.version}";
        ports = [ "${toString cfg.port}:8001" ];
        environment = {
          BASE_API_URL = "http://chibisafe_server:${toString cfg.server-port}";
        };
      };

      chibisafe_server = {
        image = "chibisafe/chibisafe-server:${cfg.version}";
        ports = [ "${toString cfg.server-port}:8000" ];
        volumes = [
          "${cfg.pathOverride.database}:/app/database:rw"
          "${cfg.pathOverride.uploads}:/app/uploads:rw"
          "${cfg.pathOverride.logs}:/app/logs:rw"
        ];
      };

      chibisafe_caddy = {
        image = "caddy:2-alpine";
        ports = [ "${toString cfg.caddy-port}:80" ];
        environment = { BASE_URL = ":80"; };
        volumes = [
          "${cfg.pathOverride.uploads}:/app/uploads:ro"
          "${Caddyfile}:/etc/caddy/Caddyfile:ro"
        ];
      };
    };
  };
}

