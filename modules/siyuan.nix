{ config, helpers, lib, ... }:

with lib;
let cfg = config.control.siyuan;
in {
  options.control.siyuan = (helpers.webServiceDefaults {
    name = "Siyuan";
    version = "latest";
    subdomain = "siyuan";
    port = 10008;
  }) // {
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
      default =
        "secret"; # REVIEW - maybe remove default to force user to specify
      defaultText = "secret";
      description = "Base password for Siyuan admin user (change this!)";
    };

    timezone = mkOption {
      type = types.str;
      default = config.time.timeZone;
      defaultText = "Your system timezone";
      description = ''
        Set the appropriate timezone for your location from
        https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
        Defaults to your system configuration (config.time.timeZone).
      '';
    };
  };

  config = mkIf cfg.enable {
    

    warnings = (optionals (cfg.admin-password == "secret") [
      "You should change the default admin password for Siyuan! control.siyuan.admin-password"
    ]);

    # Creating directory with the user id asked by the container
    systemd.tmpfiles.rules = [ "d ${cfg.paths.default} 0755 1000 1000" ];
    virtualisation.oci-containers.containers = {
      siyuan = {
        image = "b3log/siyuan:${cfg.version}";
        ports = [(helpers.webServicePort config cfg 6806)];
        extraOptions =
          [ (mkIf config.control.updateContainers "--pull=always") ];
        environment = {
          #PUID = "1000";
          #PGID = "1000";
          TZ = cfg.timezone;
          SIYUAN_WORKSPACE_PATH = "/data";
          SIYUAN_ACCESS_AUTH_CODE = cfg.admin-password;
        };
        volumes = [ "${cfg.paths.default}:/data" ];
      };
    };
  };
}

