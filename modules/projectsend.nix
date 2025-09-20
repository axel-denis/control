{ config, helpers, lib, ... }:

with lib;
let cfg = config.homeserver.projectsend;
in {
  options.homeserver.projectsend = {
    enable = mkEnableOption "Enable ProjectSend";

    version = mkOption {
      type = types.string;
      default = "latest";
      defaultText = "latest";
      description = "Version name to use for ProjectSend images";
    };

    port = mkOption {
      type = types.int;
      default = 10006;
      defaultText = "10006";
      description = "Port to use for ProjectSend";
    };

    paths = {
      default = mkOption {
        type = types.path;
        description = "Root path for ProjectSend (required)";
      };

      data = helpers.mkInheritedPathOption {
        parentName = "paths.default";
        parent = cfg.paths.default;
        defaultSubpath = "data";
        description = "Path for ProjectSend data (movies).";
      };

      config = helpers.mkInheritedPathOption {
        parentName = "paths.default";
        parent = cfg.paths.default;
        defaultSubpath = "config";
        description = "Path for ProjectSend config (config).";
      };
    };

    admin-password = mkOption {
      type = types.string;
      default = "secret"; # REVIEW - maybe remove default to force user to specify
      defaultText = "secret";
      description = "Base password for ProjectSend admin user (change this!)";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;
    virtualisation.oci-containers.backend = "docker";

    # Creating directory with the user id asked by the container
    systemd.tmpfiles.rules = [
      "d ${cfg.paths.data} 0755 1000 1000"
      "d ${cfg.paths.config} 0755 1000 1000"
    ];
    virtualisation.oci-containers.containers = {
      projectsend = {
        image = "psitrax/projectsend:${cfg.version}";
        ports = [ "${toString cfg.port}:80" ];
        environment = {
          PUID="1000";
          PGID="1000";
          TZ="Etc/UTC";
        };
        volumes = [
          "${cfg.paths.data}:/data"
          "${cfg.paths.config}:/config"
        ];
      };
    };
  };
}

