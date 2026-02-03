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

    ssh-port = lib.mkOption {
      type = lib.types.int;
      default = 44;
      defaultText = toString 44;
      description = "SSH port to use for GitLab";
    };

    paths = {
      default = helpers.mkInheritedPathOption {
        parentName = "home server global default path";
        parent = config.control.defaultPath;
        defaultSubpath = "gitlab";
        description = "Root path for GitLab";
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

    virtualisation.oci-containers.containers = {
      gitlab = {
        image = "gitlab/gitlab-ce:${cfg.version}";
        ports = (helpers.webServicePort config cfg 80) ++ ["${toString cfg.ssh-port}:22"];
        extraOptions =
          [ (mkIf config.control.updateContainers "--pull=always") "--shm-size=256m" ];
        environment = {
          GITLAB_OMNIBUS_CONFIG =
            ''
              external_url 'https://${cfg.subdomain}.${config.control.routing.domain}';
              gitlab_rails['lfs_enabled'] = true;
              gitlab_rails['gitlab_shell_ssh_port'] = ${toString cfg.ssh-port};
              letsencrypt['enabled'] = false;
              nginx['enable'] = true;
              nginx['listen_port'] = 80;
              nginx['listen_https'] = false;
            '';
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
