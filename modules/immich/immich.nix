{ config, helpers, lib, ... }:

with lib;

let cfg = config.myhomeserver.immich; # gets the config values the user has set
in {
  options.myhomeserver.immich = {
    enable = mkEnableOption "Enable Immich container";

    rootPath = mkOption {
      type = types.path;
      description = "Root path for Immich data (required)";
    };

    dbPassword = mkOption {
      type = types.string;
      description = ''
        Postgres password for Immich.
      '';
    };

    version = mkOption {
      type = types.string;
      default = "release";
      defaultText = "release";
      description = "Version name to use for Immich images";
    };

    port = mkOption {
      type = types.int;
      default = 2283;
      defaultText = "2283";
      description = "Port to use for Immich";
    };

    pathOverride = {
      database = helpers.mkInheritedPathOption {
        parentName = "rootPath";
        parent = cfg.rootPath;
        defaultSubpath = "db";
        description = "Path for Immich database.";
      };

      uploads = helpers.mkInheritedPathOption {
        parentName = "rootPath";
        parent = cfg.rootPath;
        defaultSubpath = "pictures";
        description = "Path for Immich uploads (pictures).";
      };

      machineLearning = helpers.mkInheritedPathOption {
        parentName = "rootPath";
        parent = cfg.rootPath;
        defaultSubpath = "machine_learning";
        description = "Path for Immich appdata (machine learning model cache).";
      };
    };
  };

  config = mkIf cfg.enable {

    # REVIEW - maybe not useful as unset paths without defaults should crash ?
    # assertions = [
    #   {
    #     assertion = cfg.rootPath != "";
    #     message = "You must specify myhomeserver.immich.rootPath";
    #   }
    #   {
    #     assertion = cfg.dbPassword != "";
    #     message = "You must specify myhomeserver.immich.dbPassword";
    #   }
    # ];

    # Enable Docker
    virtualisation.docker.enable = true;

    # Define Docker containers for Immich
    virtualisation.oci-containers.containers = {
      immich = {
        image = "ghcr.io/immich-app/immich-server:${toString cfg.version}";
        ports = [ "${toString cfg.port}:2283" ];
        environment = {
          IMMICH_VERSION = toString cfg.version;
          DB_HOSTNAME = "immich_postgres";
          DB_USERNAME = "immich";
          DB_DATABASE_NAME = "immich";
          DB_PASSWORD = cfg.dbPassword;
          REDIS_HOSTNAME = "immich_redis";
        };
        volumes = [
          "${cfg.pathOverride.uploads}:/usr/src/app/upload"
          "/etc/localtime:/etc/localtime:ro"
        ];
        extraOptions = [ "--network=immich-net" ];
      };

      immich_machine_learning = {
        image =
          "ghcr.io/immich-app/immich-machine-learning:${toString cfg.version}";
        environment = { IMMICH_VERSION = toString cfg.version; };
        volumes = [ "${cfg.machineLearning}/model-cache:/cache" ];
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
          POSTGRES_PASSWORD = cfg.dbPassword;
          POSTGRES_USER = "immich";
          POSTGRES_DB = "immich";
        };
        volumes = [ "${cfg.pathOverride.database}:/var/lib/postgresql/data" ];
        extraOptions = [ "--network=immich-net" ];
      };
    };

    systemd.services = helpers.mkDockerNetworkService {
      networkName = "immich-net";
      dockerCli = "${config.virtualisation.docker.package}/bin/docker";
    };
  };
}
