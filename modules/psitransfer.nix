{ config, helpers, lib, ... }:

with lib;
let cfg = config.control.psitransfer;
in {
  options.control.psitransfer = (helpers.webServiceDefaults {
    name = "Psitransfer";
    version = "latest";
    subdomain = "psitransfer";
    port = 10005;
  }) // {
    paths = {
      default = helpers.mkInheritedPathOption {
        parentName = "home server global default path";
        parent = config.control.defaultPath;
        defaultSubpath = "psitransfer";
        description = "Root path for Psitransfer media and appdata";
      };
    };

    admin-password = mkOption {
      type = types.str;
      default =
        "secret"; # REVIEW - maybe remove default to force user to specify
      defaultText = "secret";
      description = "Base password for Psitransfer admin user (change this!)";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;
    virtualisation.oci-containers.backend = "docker";

    warnings = (optionals (cfg.admin-password == "secret") [
      "You should change the default admin password for Psitransfer! control.psitransfer.admin-password"
    ]);

    virtualisation.oci-containers.containers = {
      psitransfer = {
        image = "psitrax/psitransfer:${cfg.version}";
        ports = helpers.webServicePort config cfg 3000;
        extraOptions =
          [ (mkIf config.control.updateContainers "--pull-always") ];
        environment = {
          PUID = "0";
          PGID = "0";
          PSITRANSFER_ADMIN_PASS = cfg.admin-password;
        };
        volumes = [ "${cfg.paths.default}:/data" ];
      };
    };
  };
}
