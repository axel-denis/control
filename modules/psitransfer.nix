{ config, helpers, lib, ... }:

with lib;
let 
  cfg = config.control.psitransfer;
  isolation = config.control.isolation;
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
    
    users = helpers.moduleUserHelper "control-psitransfer" 10005 isolation cfg.groups ;

    warnings = (optionals (cfg.admin-password == "secret") [
      "You should change the default admin password for Psitransfer! control.psitransfer.admin-password"
    ]);

    home-manager.users.control-psitransfer = { pkgs, confg, ...}: {
      systemd.user.enable = true;
      home.stateVersion = "25.05";

      services.podman.containers = {
        psitransfer = {
          autoStart = true;
          image = "psitrax/psitransfer:${cfg.version}";
          ports = [(helpers.webServicePort config cfg 3000)];
          userns = "keep-id"; # remove ?
          extraOptions =
            [ (mkIf config.control.updateContainers "--pull=always") ];
          environment = {
            # PUID = "10005";
            # PGID = "10005";
            PSITRANSFER_ADMIN_PASS = cfg.admin-password;
          };
          volumes = [ "${cfg.paths.default}:/data" ];
        };
      };
    };
  };
}
