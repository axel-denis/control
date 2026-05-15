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

  config = helpers.controlContainer cfg.enable name {
    warnings = (
      optionals (cfg.admin-password == "secret") [
        "You should change the default admin password for Psitransfer! control.psitransfer.admin-password"
      ]
    );

    # Creating directory with the user id asked by the container
    # systemd.tmpfiles.rules = [ "d ${cfg.paths.default} 0755 1000 1000" ];
    virtualisation.oci-containers.containers = {
      ${name} = {
        podman.user = helpers.toUsername name;
        image = "psitrax/psitransfer:${cfg.version}";
        ports = helpers.webServicePort config cfg 3000;
        extraOptions = [ (mkIf config.control.updateContainers "--pull=always") ];
        environment = {
          # PUID = "0";
          # PGID = "0";
          PSITRANSFER_ADMIN_PASS = cfg.admin-password;
        };
        volumes = [ "${cfg.paths.default}:/data" ];
      };
    };
  };
}
