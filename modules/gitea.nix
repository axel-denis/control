{
  config,
  helpers,
  lib,
  ...
}:

with lib;
let
  cfg = config.control.gitea;
  name = "gitea";
in
{
  options.control.gitea =
    (helpers.webServiceDefaults {
      name = helpers.toName name;
      version = "latest";
      subdomain = name;
      port = 10013;
    })
    // {

      ssh-port = lib.mkOption {
        type = lib.types.int;
        default = 45;
        defaultText = toString 45;
        description = "SSH port to use for Gitea";
      };

      enable-registration = mkEnableOption "Enable open registration for Gitea";

      sql-password = mkOption {
        type = types.str;
        description = "Password for SQL database";
      };

      paths = {
        default = helpers.mkInheritedPathOption {
          parentName = "home server global default path";
          parent = config.control.defaultPath;
          defaultSubpath = name;
          description = "Root path for Gitea";
        };

        database = helpers.mkInheritedPathOption {
          parentName = "paths.default";
          parent = cfg.paths.default;
          defaultSubpath = "database";
          description = "Path for Gitea database";
        };
      };
    };

  config =
    helpers.controlContainer cfg.enable name
      (with cfg; [
        paths.default
        paths.database
      ])
      config.control.enableControl3Migration
      {
        virtualisation.oci-containers.containers = {
          ${name} = {
            podman.user = helpers.toUsername name;
            image = "docker.gitea.com/gitea:${cfg.version}";
            ports = (helpers.webServicePort config cfg 3000) ++ [ "${toString cfg.ssh-port}:22" ];
            environment = {
              USER_UID = "1000";
              USER_GID = "1000";
              DISABLE_REGISTRATION = if cfg.enable-registration then "false" else "true";
            };
            volumes = [
              "${cfg.paths.default}:/data"
              "/etc/timezone:/etc/timezone:ro"
              "/etc/localtime:/etc/localtime:ro"
            ];
            extraOptions = [
              (mkIf config.control.updateContainers "--pull=always")
              "--userns=keep-id"
              "--group-add=keep-groups"
            ];
          };

          "${name}_db" = {
            podman.user = helpers.toUsername name;
            image = "docker.io/library/mysql:8";
            environment = {
              MYSQL_ROOT_PASSWORD = cfg.password;
              MYSQL_USER = "gitea";
              MYSQL_PASSWORD = cfg.password;
              MYSQL_DATABASE = "gitea";
            };
            extraOptions = [
              (mkIf config.control.updateContainers "--pull=always")
              "--userns=keep-id"
              "--group-add=keep-groups"
            ];
            volumes = [
              "${cfg.paths.database}:/var/lib/mysql"
            ];
          };
        };
      };
}
