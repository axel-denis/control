{ config, pkgs, lib, helpers, ... }:
with lib;
let cfg = config.control.picard;
in {
  options.control.picard = (helpers.webServiceDefaults {
    name = "picard";
    version = "latest";
    subdomain = "picard";
    port = 10014;
  }) // {
    paths = {
      default = helpers.mkInheritedPathOption {
        parentName = "home server global default path";
        parent = config.control.defaultPath;
        defaultSubpath = "picard";
        description = "Root path for picard media and appdata";
      };

      directories = lib.mkOption {
        type = with types; attrsOf path;
        default = { "config" = cfg.paths.default + "/config"; };
        defaultText = ''{config = paths.default + "/config";}'';
        description = ''
          List of mountpoints giving data to the picard container.
          Will be mounted under /<name> in the container.
        '';
      };
    };

    configuration = lib.mkOption {
      type = with types; attrsOf str;
      default = { };
      defaultText = "{ }";
      description = "Passed as environment to picard. See picard(docker) docs";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;
    virtualisation.oci-containers.backend = "docker";

    users.users.picard = {
      isNormalUser = true;
      uid = 1095;
      group = "music";
      extraGroups = [ "docker" "users" ];
    };

    virtualisation.oci-containers.containers = {
      picard = {
        image = "mikenye/picard:${cfg.version}";
        ports = helpers.webServicePort config cfg 5800;
        extraOptions = [ "--pull=always" ];
        environment = mkMerge [
          cfg.configuration
          {
            USER_ID = "1095";
            GROUP_ID = "990";
            KEEP_APP_RUNNING = "true";
            CLEAN_TMP_DIR = "false"; # Prevent config reset after each restart
          }
        ];
        volumes = helpers.multiplesVolumes cfg.paths.directories "";
      };
    };
  };
}

