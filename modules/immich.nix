{ config, helpers, lib, ... }:

with lib;
let cfg = config.homeserver.immich; # (gets the config values the user has set)
in {
  options.homeserver.immich = {
    enable = mkEnableOption "Enable Immich container";

    dbPasswordFile = mkOption {
      type = types.path;
      description = ''
        Path of Postgres password file for Immich.
      '';
    };

    version = mkOption {
      type = types.str;
      default = "release";
      defaultText = "release";
      description = "Version name to use for Immich images";
    };

    port = mkOption {
      type = types.int;
      default = 10001;
      defaultText = "10001";
      description = "Port to use for Immich";
    };

    forceLan = mkEnableOption ''
        Force LAN access, ignoring router configuration.
        You will be able to access this container on <lan_ip>:${toString cfg.port} regardless of your router configuration.
    '';

    basicAuth = mkOption {
      type = with types; attrsOf str;
      default = { };
      description = ''
        If set, enable Nginx basic authentication for this service.
        The value should be an attribute set of username-password pairs, e.g.
        { user1 = "password1"; user2 = "password2"; }
        Keep in mind that basic authentication works for web pages but can break dependant services (e.g. mobile apps).
      '';
    };

    # ANCHOR - simple ctrl-shift-f insert for all webservices

    subdomain = mkOption {
      type = types.str;
      default = "immich";
      defaultText = "immich";
      description = "Subdomain to use for Immich";
    };

    paths = {
      default = helpers.mkInheritedPathOption {
        parentName = "home server global default path";
        parent = config.homeserver.defaultPath;
        defaultSubpath = "immich";
        description = "Default path for Immich data";
      };

      database = helpers.mkInheritedPathOption {
        parentName = "paths.default";
        parent = cfg.paths.default;
        defaultSubpath = "db";
        description = "Path for Immich database.";
      };

      uploads = helpers.mkInheritedPathOption {
        parentName = "paths.default";
        parent = cfg.paths.default;
        defaultSubpath = "pictures";
        description = "Path for Immich uploads (pictures).";
      };

      machineLearning = helpers.mkInheritedPathOption {
        parentName = "paths.default";
        parent = cfg.paths.default;
        defaultSubpath = "machine_learning";
        description = "Path for Immich appdata (machine learning model cache).";
      };
    };
  };

  config = mkIf cfg.enable {

    virtualisation.docker.enable = true;
    virtualisation.oci-containers.backend = "docker";

    virtualisation.oci-containers.containers = {
      immich = {
        image = "ghcr.io/immich-app/immich-server:${cfg.version}";
        ports = [ "${if (config.homeserver.routing.lan || cfg.forceLan) then "" else "127.0.0.1:"}${toString cfg.port}:2283" ];
        environment = {
          IMMICH_VERSION = toString cfg.version;
          DB_HOSTNAME = "immich_postgres";
          DB_USERNAME = "immich";
          DB_DATABASE_NAME = "immich";
          DB_PASSWORD_FILE = "/run/secrets/immich-db-password";
          REDIS_HOSTNAME = "immich_redis";
        };
        volumes = [
          "${cfg.paths.uploads}:/usr/src/app/upload"
          "/etc/localtime:/etc/localtime:ro"
          "${cfg.dbPasswordFile}:/run/secrets/immich-db-password:ro"
        ];
        extraOptions = [ "--network=immich-net" ];
      };

      immich_machine_learning = {
        image =
          "ghcr.io/immich-app/immich-machine-learning:${toString cfg.version}";
        environment = { IMMICH_VERSION = toString cfg.version; };
        volumes = [ "${cfg.paths.machineLearning}/model-cache:/cache" ];
        extraOptions = [ "--network=immich-net" ];
      };

      immich_redis = {
        image =
          "redis:6.2-alpine@sha256:905c4ee67b8e0aa955331960d2aa745781e6bd89afc44a8584bfd13bc890f0ae";
        extraOptions = [ "--network=immich-net" ];
      };

      immich_postgres = {
        image =
          "tensorchord/pgvecto-rs:pg14-v0.2.0@sha256:90724186f0a3517cf6914295b5ab410db9ce23190a2d9d0b9dd6463e3fa298f0";
        environment = {
          POSTGRES_PASSWORD_FILE = "/run/secrets/immich-db-password";
          POSTGRES_USER = "immich";
          POSTGRES_DB = "immich";
        };
        volumes = [
          "${cfg.paths.database}:/var/lib/postgresql/data"
          "${cfg.dbPasswordFile}:/run/secrets/immich-db-password:ro"
        ];
        extraOptions = [ "--network=immich-net" ];
      };
    };

    systemd.services = helpers.mkDockerNetworkService {
      networkName = "immich-net";
      dockerCli = "${config.virtualisation.docker.package}/bin/docker";
    };
  };
}
