{ config, helpers, lib, ... }:

with lib;
let cfg = config.control.gitea;
in {
  options.control.gitea = (helpers.webServiceDefaults {
    name = "Gitea";
    version = "latest";
    subdomain = "gitea";
    port = 10013;
  }) // {

    ssh-port = lib.mkOption {
      type = lib.types.int;
      default = 45;
      defaultText = toString 45;
      description = "SSH port to use for Gitea";
    };

    paths = {
      default = helpers.mkInheritedPathOption {
        parentName = "home server global default path";
        parent = config.control.defaultPath;
        defaultSubpath = "gitea";
        description = "Root path for Gitea";
      };
    };
  };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;
    virtualisation.oci-containers.backend = "docker";

    virtualisation.oci-containers.containers = {
      gitea = {
        image = "docker.gitea.com/gitea:${cfg.version}";
        ports = (helpers.webServicePort config cfg 3000) ++ ["${toString cfg.ssh-port}:22"];
        environment = {
          USER_UID = "1000";
          USER_GID = "1000";
        };
        volumes = [ 
          "${cfg.paths.default}:/data"
          "/etc/timezone:/etc/timezone:ro"
          "/etc/localtime:/etc/localtime:ro"
        ];
        extraOptions = [
          "--network=gitea-net"
          (mkIf config.control.updateContainers "--pull=always")
        ];
      };

      gitea-db = {
        image = "docker.io/library/mysql:8";
        environment = {
          MYSQL_ROOT_PASSWORD= "gitea";
          MYSQL_USER= "gitea";
          MYSQL_PASSWORD= "gitea";
          MYSQL_DATABASE= "gitea";
        };
        extraOptions = [
          "--network=gitea-net"
          (mkIf config.control.updateContainers "--pull=always")
        ];
      };
    };

    systemd.services = helpers.mkDockerNetworkService {
      networkName = "gitea-net";
      dockerCli = "${config.virtualisation.docker.package}/bin/docker";
    };
  };
}
