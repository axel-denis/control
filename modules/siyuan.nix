{
  config,
  helpers,
  lib,
  ...
}:

with lib;
let
  cfg = config.control.siyuan;
  name = "siyuan";
in
{
  options.control.siyuan =
    (helpers.webServiceDefaults {
      name = helpers.toName name;
      version = "latest";
      subdomain = name;
      port = 10008;
    })
    // {
      paths = {
        default = helpers.mkInheritedPathOption {
          parentName = "home server global default path";
          parent = config.control.defaultPath;
          defaultSubpath = name;
          description = "Root path for Siyuan media and appdata";
        };
      };

      admin-password = mkOption {
        type = types.str;
        default = "secret"; # REVIEW - maybe remove default to force user to specify
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

  config =
    helpers.controlContainer cfg.enable name (with cfg; [ paths.default ])
      config.control.enableControl3Migration
      {
        warnings = (
          optionals (cfg.admin-password == "secret") [
            "You should change the default admin password for Siyuan! control.siyuan.admin-password"
          ]
        );

        virtualisation.oci-containers.containers = {
          ${name} = {
            podman.user = helpers.toUsername name;
            image = "b3log/siyuan:${cfg.version}";
            ports = helpers.webServicePort config cfg 6806;
            extraOptions = [ (mkIf config.control.updateContainers "--pull=always") ];
            environment = {
              TZ = cfg.timezone;
              SIYUAN_WORKSPACE_PATH = "/data";
              SIYUAN_ACCESS_AUTH_CODE = cfg.admin-password;
            };
            volumes = [ "${cfg.paths.default}:/data" ];
          };
        };
      };
}
