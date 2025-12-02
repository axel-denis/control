{ config, helpers, lib, ... }:

with lib;
let cfg = config.control.cloudreve;
in {
  options.control.cloudreve = (helpers.webServiceDefaults {
    name = "Cloudreve";
    version = "latest";
    subdomain = "cloudreve";
    port = 10011;
  }) // {
    dbIsHdd = mkEnableOption ''
      Enable if `paths.database`points to an HDD drive.
    '';

    paths = {
      default = helpers.mkInheritedPathOption {
        parentName = "home server global default path";
        parent = config.control.defaultPath;
        defaultSubpath = "cloudreve";
        description = "Default path for Cloudreve data";
      };

      database = helpers.mkInheritedPathOption {
        parentName = "paths.default";
        parent = cfg.paths.default;
        defaultSubpath = "database";
        description = "Path for Cloudreve database.";
      };

      redis = helpers.mkInheritedPathOption {
        parentName = "paths.default";
        parent = cfg.paths.default;
        defaultSubpath = "redis";
        description = "Path for Cloudreve redis.";
      };

      uploads = helpers.mkInheritedPathOption {
        parentName = "paths.default";
        parent = cfg.paths.default;
        defaultSubpath = "uploads";
        description = "Path for Cloudreve uploads (pictures).";
      };
    };
  };

  config = mkIf cfg.enable {

    
    virtualisation.oci-containers.containers = {
      cloudreve = {
        image = "cloudreve/cloudreve:${cfg.version}";
        ports = helpers.webServicePort config cfg 5212
          ++ [ "6888:6888" "6888:6888/udp" ];
        environment = {
          "CR_CONF_Database.Type" = "postgres";
          "CR_CONF_Database.Host" = "cloudreve-postgresql";
          "CR_CONF_Database.User" = "cloudreve";
          "CR_CONF_Database.Name" = "cloudreve";
          "CR_CONF_Database.Port" = "5432";
          "CR_CONF_Redis.Server" = "cloudreve-redis:6379";
        };
        volumes = [ "${cfg.paths.uploads}:/cloudreve/data" ];
        extraOptions = [ "--network=cloudreve-net" "--pull=always" ];
      };

      cloudreve-postgresql = {
        image = "postgres:17";
        environment = {
          POSTGRES_USER = "cloudreve";
          POSTGRES_DB = "cloudreve";
          POSTGRES_HOST_AUTH_METHOD = "trust";
          DB_STORAGE_TYPE = mkIf cfg.dbIsHdd "HDD";
        };
        volumes = [ "${cfg.paths.database}:/var/lib/postgresql/data" ];
        extraOptions = [ "--network=cloudreve-net" "--pull=always" ];
      };

      cloudreve-redis = {
        image = "redis:latest";
        volumes = [ "${cfg.paths.redis}:/data" ];
        extraOptions = [ "--network=cloudreve-net" "--pull=always" ];
      };
    };

    systemd.services = helpers.mkNetworkService {
      networkName = "cloudreve-net";
      dockerCli = "${config.virtualisation.docker.package}/bin/podman";
    };
  };
}
