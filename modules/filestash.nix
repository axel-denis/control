{ config, pkgs, lib, helpers, ... }:
with lib;
let cfg = config.control.filestash;
in {
  options.control.filestash = (helpers.webServiceDefaults {
    name = "filestash";
    version = "latest";
    subdomain = "filestash";
    port = 10013;
  }) // {
    paths = {
      default = helpers.mkInheritedPathOption {
        parentName = "home server global default path";
        parent = config.control.defaultPath;
        defaultSubpath = "filestash";
        description = "Root path for filestash media and appdata";
      };

      directories = lib.mkOption {
        type = with types; attrsOf path;
        default = { "storage" = cfg.paths.default + "/storage"; };
        defaultText = ''{storage = paths.default + "/storage";}'';
        description = ''
          List of mountpoints giving data to the filestash container.
          Will be mounted under /<name> in the container.
        '';
      };
    };

    configuration = lib.mkOption {
      type = with types; attrsOf str;
      default = { };
      defaultText = "{ }";
      description = "Passed as environment to filestash. See filestash docs";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;
    virtualisation.oci-containers.backend = "docker";

    users.users.filestash = {
      isNormalUser = true;
      uid = 1097;
      group = "music";
      extraGroups = [ "docker" "users" ];
    };

    virtualisation.oci-containers.containers = {
      filestash = {
        image = "machines/filestash:${cfg.version}";
        ports = helpers.webServicePort config cfg 8334;
        extraOptions = [ "--pull=always" ];
        environment = cfg.configuration;
        user="1000:990";
        volumes = helpers.multiplesVolumes cfg.paths.directories "";
      };
    };
  };
}

