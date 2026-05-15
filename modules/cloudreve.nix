{
  config,
  helpers,
  lib,
  ...
}:

with lib;
let
  cfg = config.control.cloudreve;
  name = "cloudreve";
in
{
  options.control.cloudreve =
    (helpers.webServiceDefaults {
      name = helpers.toName name;
      version = "latest";
      subdomain = name;
      port = 10011;
    })
    // {
      dbIsHdd = mkEnableOption ''
        Enable if `paths.database`points to an HDD drive.
      '';

      paths = {
        default = helpers.mkInheritedPathOption {
          parentName = "home server global default path";
          parent = config.control.defaultPath;
          defaultSubpath = name;
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

  config = helpers.controlContainer cfg.enable name ({
    virtualisation.oci-containers.containers = {
      ${name} = {
        podman.user = helpers.toUsername name;
        image = "cloudreve/cloudreve:${cfg.version}";
        ports = helpers.webServicePort config cfg 5212 ++ [
          "6888:6888"
          "6888:6888/udp"
        ];
        environment = {
          "CR_CONF_Database.Type" = "postgres";
          "CR_CONF_Database.Host" = "cloudreve-postgresql";
          "CR_CONF_Database.User" = "cloudreve";
          "CR_CONF_Database.Name" = "cloudreve";
          "CR_CONF_Database.Port" = "5432";
          "CR_CONF_Redis.Server" = "cloudreve-redis:6379";
        };
        volumes = [ "${cfg.paths.uploads}:/cloudreve/data" ];
        extraOptions = [
          (mkIf config.control.updateContainers "--pull=always")
        ];
      };

      cloudreve-postgresql = {
        podman.user = helpers.toUsername name;
        image = "postgres:17";
        environment = {
          POSTGRES_USER = "cloudreve";
          POSTGRES_DB = "cloudreve";
          POSTGRES_HOST_AUTH_METHOD = "trust";
          DB_STORAGE_TYPE = mkIf cfg.dbIsHdd "HDD";
        };
        volumes = [ "${cfg.paths.database}:/var/lib/postgresql/data" ];
        extraOptions = [
          (mkIf config.control.updateContainers "--pull=always")
        ];
      };

      cloudreve-redis = {
        podman.user = helpers.toUsername name;
        image = "redis:latest";
        volumes = [ "${cfg.paths.redis}:/data" ];
        extraOptions = [
          (mkIf config.control.updateContainers "--pull=always")
        ];
      };
    };
  });
}
