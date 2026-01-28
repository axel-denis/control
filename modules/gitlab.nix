{ config, helpers, lib, ... }:

with lib;
let cfg = config.control.gitlab;
in {
  options.control.gitlab = (helpers.webServiceDefaults {
    name = "GitLab";
    version = "latest";
    subdomain = "gitlab";
    port = 10012;
  }) // {
    paths = {
      default = helpers.mkInheritedPathOption {
        parentName = "home server global default path";
        parent = config.control.defaultPath;
        defaultSubpath = "gitlab";
        description = "Root path for GitLab media and appdata";
      };

      config = helpers.mkInheritedPathOption {
        parentName = "paths.default";
        parent = cfg.paths.default;
        defaultSubpath = "config";
        description = "Path for GitLab config.";
      };

      logs = helpers.mkInheritedPathOption {
        parentName = "paths.default";
        parent = cfg.paths.default;
        defaultSubpath = "logs";
        description = "Path for GitLab logs.";
      };

      data = helpers.mkInheritedPathOption {
        parentName = "paths.default";
        parent = cfg.paths.default;
        defaultSubpath = "data";
        description = "Path for GitLab data";
      };
    };
  };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;
    virtualisation.oci-containers.backend = "docker";

    warnings = (optionals (cfg.admin-password == "secret") [
      "You should change the default admin password for GitLab! control.gitlab.admin-password"
    ]);

    # Creating directory with the user id asked by the container
    systemd.tmpfiles.rules = [ "d ${cfg.paths.default} 0755 1000 1000" ];
    virtualisation.oci-containers.containers = {
      gitlab = {
        image = "psitrax/gitlab:${cfg.version}";
        ports = (helpers.webServicePort config cfg 80) ++ "22:22";
        extraOptions =
          [ (mkIf config.control.updateContainers "--pull=always") "--shm-size=256m" ];
        environment = {
          GITLAB_OMNIBUS_CONFIG =
            "external_url ${cfg.subdomain}.${config.control.routing.domain}; gitlab_rails['lfs_enabled'] = true;";
        };
        volumes = [ 
          "${cfg.paths.config}:/etc/gitlab"
          "${cfg.paths.logs}:/var/logs/gitlab"
          "${cfg.paths.data}:/var/opt/gitlab"
        ];
      };
    };
  };
}
