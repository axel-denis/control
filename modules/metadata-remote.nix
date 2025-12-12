{ config, pkgs, lib, helpers, ... }:
with lib;
let cfg = config.control.metadata-remote;
in {
  options.control.metadata-remote = (helpers.webServiceDefaults {
    name = "metadata-remote";
    version = "latest";
    subdomain = "metadata";
    port = 10012;
  }) // {
    paths = {
      default = helpers.mkInheritedPathOption {
        parentName = "home server global default path";
        parent = config.control.defaultPath;
        defaultSubpath = "metadata";
        description = "Root path for metadata-remote media and appdata";
      };

      directories = lib.mkOption {
        type = with types; attrsOf path;
        default = { "music" = cfg.paths.default + "/music"; };
        defaultText = ''{music = paths.default + "/music";}'';
        description = ''
          List of mountpoints giving data to the metadata-remote container.
          Will be mounted under /<name> in the container.
        '';
      };
    };

    configuration = lib.mkOption {
      type = with types; attrsOf str;
      default = { };
      defaultText = "{ }";
      description = "Passed as environment to metadata-remote. See metadata-remote docs";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;
    virtualisation.oci-containers.backend = "docker";

    users.users.metadata = {
      isNormalUser = true;
      uid = 1094;
      group = "music";
      extraGroups = [ "docker" "users" ];
    };

    virtualisation.oci-containers.containers = {
      metadata-remote = {
        image = "ghcr.io/wow-signal-dev/metadata-remote:${cfg.version}";
        ports = helpers.webServicePort config cfg 8338;
        extraOptions = [ "--pull=always" ];
        environment = mkMerge [
          cfg.configuration
          {
            PUID = "1094";
            PGID = "990";
          }
        ];
        volumes = helpers.multiplesVolumes cfg.paths.directories "";
      };
    };
  };
}

