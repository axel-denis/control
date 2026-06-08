{
  config,
  helpers,
  lib,
  ...
}:

with lib;
let
  cfg = config.control.psitransfer;
  name = "psitransfer";
in
{
  options.control.psitransfer =
    (helpers.webServiceDefaults {
      name = helpers.toName name;
      version = "latest";
      subdomain = name;
      port = 10005;
    })
    // {
      paths = {
        default = helpers.mkInheritedPathOption {
          parentName = "home server global default path";
          parent = config.control.defaultPath;
          defaultSubpath = name;
          description = "Root path for Psitransfer media and appdata";
        };
      };

      admin-password = mkOption {
        type = types.str;
        default = "secret"; # REVIEW - maybe remove default to force user to specify
        defaultText = "secret";
        description = "Base password for Psitransfer admin user (change this!)";
      };
    };

  config =
    helpers.controlContainer cfg.enable name (with cfg; [ paths.default ])
      config.control.enableControl3Migration
      {
        warnings = (
          optionals (cfg.admin-password == "secret") [
            "You should change the default admin password for Psitransfer! control.psitransfer.admin-password"
          ]
        );

        virtualisation.oci-containers.containers = {
          ${name} = {
            podman.user = helpers.toUsername name;
            image = "psitrax/psitransfer:${cfg.version}";
            ports = helpers.webServicePort config cfg 3000;
            extraOptions = [
              (mkIf config.control.updateContainers "--pull=always")
              "--userns=keep-id"
              "--group-add=keep-groups"
            ];
            environment = {
              PSITRANSFER_ADMIN_PASS = cfg.admin-password;
            };
            volumes = [ "${cfg.paths.default}:/data" ];
          };
        };
      };
}
