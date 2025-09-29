{ config, helpers, lib, ... }:

with lib;
let cfg = config.homeserver.psitransfer;
in {
  options.homeserver.psitransfer = {
    enable = mkEnableOption "Enable Psitransfer";

    version = mkOption {
      type = types.str;
      default = "latest";
      defaultText = "latest";
      description = "Version name to use for Psitransfer images";
    };

    subdomain = mkOption {
      type = types.str;
      default = "psitransfer";
      defaultText = "psitransfer";
      description = "Subdomain to use for Psitransfer";
    };

    port = mkOption {
      type = types.int;
      default = 10005;
      defaultText = "10005";
      description = "Port to use for Psitransfer";
    };

    forceLan = mkOption {
      type = types.bool;
      default = false;
      description = "Force LAN access, ignoring router configuration.";
    };

    paths = {
      default = helpers.mkInheritedPathOption {
        parentName = "home server global default path";
        parent = config.homeserver.defaultPath;
        defaultSubpath = "psitransfer";
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

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;
    virtualisation.oci-containers.backend = "docker";

    # Creating directory with the user id asked by the container
    systemd.tmpfiles.rules = [
      "d ${cfg.paths.default} 0755 1000 1000"
    ];
    virtualisation.oci-containers.containers = {
      psitransfer = {
        image = "psitrax/psitransfer:${cfg.version}";
        ports = [ "${if (config.homeserver.routing.lan || cfg.forceLan) then "" else "127.0.0.1:"}${toString cfg.port}:3000" ];
        environment = {
          PUID="0";
          PGID="0";
          PSITRANSFER_ADMIN_PASS = cfg.admin-password;
        };
        volumes = [
          "${cfg.paths.default}:/data"
        ];
      };
    };
  };
}

