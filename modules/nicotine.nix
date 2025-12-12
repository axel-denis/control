{ config, helpers, lib, ... }:

with lib;
let cfg = config.control.nicotine;
in {
  options.control.nicotine = (helpers.webServiceDefaults {
    name = "nicotine";
    version = "latest";
    subdomain = "nicotine";
    port = 10010;
  }) // {
    paths = {
      default = helpers.mkInheritedPathOption {
        parentName = "home server global default path";
        parent = config.control.defaultPath;
        defaultSubpath = "nicotine";
        description = "Root path for nicotine media and appdata";
      };

      directories = lib.mkOption {
        type = with types; attrsOf path;
        default = { shared = cfg.paths.default + "/shared"; };
        defaultText = ''{shared = paths.default + "/shared";}'';
        description = ''
          List of mountpoints giving data to the nicotine+ container.
          Will be mounted under /<shared> in the container.
        '';
      };

      config = helpers.mkInheritedPathOption {
        parentName = "paths.default";
        parent = cfg.paths.default;
        defaultSubpath = "config";
        description = "Path for nicotine+ to save config persistently.";
      };

      data = helpers.mkInheritedPathOption {
        parentName = "paths.config";
        parent = cfg.paths.default;
        defaultSubpath = "data";
        description = "Path for nicotine+ to save logs, database, and history.";
      };

      downloads = helpers.mkInheritedPathOption {
        parentName = "paths.config";
        parent = cfg.paths.default;
        defaultSubpath = "downloads";
        description = "Path for nicotine+ to store downloaded files.";
      };
    };

    configuration = lib.mkOption {
      type = with types; attrsOf str;
      default = { };
      defaultText = "{ }";
      description = "Passed as environment to nicotine+. See nicotineplus-proper docs";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;
    virtualisation.oci-containers.backend = "docker";

    users.users.nicotine = {
      isNormalUser = true;
      uid = 1098;
      group = "music";
      extraGroups = [ "docker" "users" ];
    };

    virtualisation.oci-containers.containers = {
      nicotine = {
        image = "sirjmann92/nicotineplus-proper:${cfg.version}";
        ports = (helpers.webServicePort config cfg 6565) ++ [ "50300:50300" ];
        extraOptions = [ "--pull=always" ];
        environment = mkMerge [
          cfg.configuration
          {
            PUID="1098";
            FORWARD_PORT="50300";
            PGID="990";
          }
        ];
        volumes = [ "${cfg.paths.config}:/config" "${cfg.paths.data}:/data" "${cfg.paths.downloads}:/downloads" ] ++ helpers.multiplesVolumes cfg.paths.directories "";
      };
    };
  };
}
