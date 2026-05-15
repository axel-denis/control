{
  config,
  helpers,
  lib,
  ...
}:

with lib;
let
  cfg = config.control.immich;
  name = "immich";
in
{
  options.control.immich =
    (helpers.webServiceDefaults {
      name = helpers.toName name;
      version = "release";
      subdomain = name;
      port = 10001;
    })
    // {
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
          defaultSubpath = name;
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

  config = helpers.controlContainer cfg.enable name {
    virtualisation.oci-containers.containers = {
      "${name}_server" = {
        podman.user = helpers.toUsername name;
        image = "ghcr.io/immich-app/immich-server:${cfg.version}";
        ports = helpers.webServicePort config cfg 2283;
        environment = {
          DB_USERNAME = "postgres";
          DB_DATABASE_NAME = "immich";
          DB_PASSWORD = cfg.dbPassword;
          IMMICH_VERSION = cfg.version;
        };
        volumes = [
          "${cfg.paths.uploads}:/data"
          "/etc/localtime:/etc/localtime:ro"
        ];
        extraOptions = [
          (mkIf config.control.updateContainers "--pull=always")
        ];
      };

      "${name}_machine_learning" = {
        podman.user = helpers.toUsername name;
        image = "ghcr.io/immich-app/immich-machine-learning:${cfg.version}";
        environment = {
          DB_USERNAME = "postgres";
          DB_DATABASE_NAME = "immich";
          DB_PASSWORD = cfg.dbPassword;
          IMMICH_VERSION = cfg.version;
        };
        volumes = [ "${cfg.paths.machineLearning}:/cache" ];
        extraOptions = [
          (mkIf config.control.updateContainers "--pull=always")
        ];
      };

      "${name}_redis" = {
        podman.user = helpers.toUsername name;
        image = "docker.io/valkey/valkey:8-bookworm@sha256:fea8b3e67b15729d4bb70589eb03367bab9ad1ee89c876f54327fc7c6e618571";
        extraOptions = [
          (mkIf config.control.updateContainers "--pull=always")
        ];
      };

      "${name}_database" = {
        podman.user = helpers.toUsername name;
        image = "ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0@sha256:41eacbe83eca995561fe43814fd4891e16e39632806253848efaf04d3c8a8b84";
        environment = {
          POSTGRES_PASSWORD = cfg.dbPassword;
          POSTGRES_USER = "postgres";
          POSTGRES_DB = "immich";
          POSTGRES_INITDB_ARGS = "--data-checksums";
          DB_STORAGE_TYPE = mkIf cfg.dbIsHdd "HDD";
        };
        volumes = [ "${cfg.paths.database}:/var/lib/postgresql/data" ];
        extraOptions = [
          (mkIf config.control.updateContainers "--pull=always")
        ];
      };
    };
  };
}
