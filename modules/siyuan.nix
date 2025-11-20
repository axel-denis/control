{
  config,
  helpers,
  lib,
  ...
}:

with lib;
let
  cfg = config.control.siyuan;
in
{
  options.control.siyuan =
    (helpers.webServiceDefaults {
      name = "Siyuan";
      version = "latest";
      subdomain = "siyuan";
      port = 10008;
    })
    // {
      paths = {
        default = helpers.mkInheritedPathOption {
          parentName = "home server global default path";
          parent = config.control.defaultPath;
          defaultSubpath = "siyuan";
          description = "Root path for Siyuan media and appdata";
        };
      };

      admin-password = mkOption {
        type = types.str;
        default = "secret"; # REVIEW - maybe remove default to force user to specify
        defaultText = "secret";
        description = "Base password for Siyuan admin user (change this!)";
      };
    };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;
    virtualisation.oci-containers.backend = "docker";

    warnings = (
      optionals (cfg.admin-password == "secret") [
        "You should change the default admin password for Siyuan! control.siyuan.admin-password"
      ]
    );

    # Creating directory with the user id asked by the container
    systemd.tmpfiles.rules = [ "d ${cfg.paths.default} 0755 1000 1000" ];
    virtualisation.oci-containers.containers = {
      siyuan = {
        image = "b3log/siyuan:${cfg.version}";
        ports = helpers.webServicePort config cfg 6806;
        extraOptions = [ "--pull=always" "--workspace=/workspace_dir_container" ("--accessAuthCode=" + cfg.admin-password) ];
        environment = {
          PUID = "0";
          PGID = "0";
        };
        volumes = [ "${cfg.paths.default}:/workspace_dir_container" ];
      };
    };
  };
}



