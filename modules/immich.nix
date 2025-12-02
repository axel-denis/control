{ config, helpers, lib, ... }:

with lib;
let cfg = config.control.immich;
in {
  options.control.immich = (helpers.webServiceDefaults {
    name = "Immich";
    version = "release";
    subdomain = "immich";
    port = 10001;
  }) // {
    dbPassword = mkOption {
      type = types.str;
      description = ''
        Postgres password for Immich.
      '';
    };

    dbIsHdd = mkEnableOption ''
      Enable if `paths.database`points to an HDD drive.
    '';

    paths = {
      default = helpers.mkInheritedPathOption {
        parentName = "home server global default path";
        parent = config.control.defaultPath;
        defaultSubpath = "immich";
        description = "Default path for Immich data";
      };

      database = helpers.mkInheritedPathOption {
        parentName = "paths.default";
        parent = cfg.paths.default;
        defaultSubpath = "database";
        description = "Path for Immich database.";
      };

      uploads = helpers.mkInheritedPathOption {
        parentName = "paths.default";
        parent = cfg.paths.default;
        defaultSubpath = "uploads";
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

    

    virtualisation.oci-containers.containers = {
      immich_server = {
        image = "ghcr.io/immich-app/immich-server:${cfg.version}";
        ports = helpers.webServicePort config cfg 2283;
        environment = {
          DB_USERNAME = "postgres";
          DB_DATABASE_NAME = "immich";
          DB_PASSWORD = cfg.dbPassword;
          IMMICH_VERSION = cfg.version;
        };
        volumes =
          [ "${cfg.paths.uploads}:/data" "/etc/localtime:/etc/localtime:ro" ];
        extraOptions = [ "--network=immich-net" (mkIf config.control.updateContainers "--pull-always") ];
      };

      immich-machine-learning = {
        image = "ghcr.io/immich-app/immich-machine-learning:${cfg.version}";
        environment = {
          DB_USERNAME = "postgres";
          DB_DATABASE_NAME = "immich";
          DB_PASSWORD = cfg.dbPassword;
          IMMICH_VERSION = cfg.version;
        };
        volumes = [ "${cfg.paths.machineLearning}:/cache" ];
        extraOptions = [ "--network=immich-net" (mkIf config.control.updateContainers "--pull-always") ];
      };

      redis = {
        image =
          "docker.io/valkey/valkey:8-bookworm@sha256:fea8b3e67b15729d4bb70589eb03367bab9ad1ee89c876f54327fc7c6e618571";
        extraOptions = [ "--network=immich-net" (mkIf config.control.updateContainers "--pull-always") ];
      };

      database = {
        image =
          "ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0@sha256:41eacbe83eca995561fe43814fd4891e16e39632806253848efaf04d3c8a8b84";
        environment = {
          POSTGRES_PASSWORD = cfg.dbPassword;
          POSTGRES_USER = "postgres";
          POSTGRES_DB = "immich";
          POSTGRES_INITDB_ARGS = "--data-checksums";
          DB_STORAGE_TYPE = mkIf cfg.dbIsHdd "HDD";
        };
        volumes = [ "${cfg.paths.database}:/var/lib/postgresql/data" ];
        extraOptions = [ "--network=immich-net" (mkIf config.control.updateContainers "--pull-always") ];
      };
    };

    systemd.services = helpers.mkNetworkService {
      networkName = "immich-net";
      dockerCli = "${config.virtualisation.docker.package}/bin/podman";
    };
  };
}
