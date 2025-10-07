{ config, helpers, lib, ... }:

with lib;
let cfg = config.control.immich; # (gets the config values the user has set)
in {
  options.control.immich = {
    enable = mkEnableOption "Enable Immich container";

    dbPassword = mkOption {
      type = types.str;
      description = ''
        Postgres password for Immich.
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
      You will be able to access this container on <lan_ip>:<this_app_port> regardless of your routing module configuration.
    '';

    lanOnly = mkEnableOption ''
      Disable routing for this service. You will only be able to access it on your LAN.
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
      immich_server = {
        image = "ghcr.io/immich-app/immich-server:${cfg.version}";
        ports = [
          "${
            if (config.control.routing.lan || cfg.forceLan || cfg.lanOnly) then
              ""
            else
              "127.0.0.1:"
          }${toString cfg.port}:2283"
        ];
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
        extraOptions = [ "--network=immich-net" ];
      };

      immich_machine_learning = {
        image =
          "ghcr.io/immich-app/immich-machine-learning:${cfg.version}";
        environment = {
          DB_USERNAME = "postgres";
          DB_DATABASE_NAME = "immich";
          DB_PASSWORD = cfg.dbPassword;
          IMMICH_VERSION = cfg.version;
        };
        volumes = [ "${cfg.paths.machineLearning}:/cache" ];
        extraOptions = [ "--network=immich-net" ];
      };

      immich_redis = {
        image =
          "docker.io/valkey/valkey:8-bookworm@sha256:fea8b3e67b15729d4bb70589eb03367bab9ad1ee89c876f54327fc7c6e618571";
        extraOptions = [ "--network=immich-net" ];
      };

      immich_postgres = {
        image =
          "ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0@sha256:41eacbe83eca995561fe43814fd4891e16e39632806253848efaf04d3c8a8b84";
        environment = {
          POSTGRES_PASSWORD = cfg.dbPassword;
          POSTGRES_USER = "postgres";
          POSTGRES_DB = "immich";
          POSTGRES_INITDB_ARGS = "--data-checksums";
          DB_STORAGE_TYPE = mkIf cfg.dbIsHdd "HDD";
        };
        volumes = [
          "${cfg.paths.database}:/var/lib/postgresql/data"
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
