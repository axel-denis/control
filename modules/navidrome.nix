{ config, helpers, lib, ... }:

with lib;
let cfg = config.control.navidrome;
in {
  options.control.navidrome = (helpers.webServiceDefaults {
    name = "Navidrome";
    version = "latest";
    subdomain = "navidrome";
    port = 10002;
  }) // {
    paths = {
      default = helpers.mkInheritedPathOption {
        parentName = "home server global default path";
        parent = config.control.defaultPath;
        defaultSubpath = "navidrome";
        description = "Root path for Navidrome media and appdata";
      };

      music = lib.mkOption {
        type = with types; attrsOf path;
        default = { mymusic = parent + "/music"; };
        defaultText = ''{mymusic = paths.default + "/music";}'';
        description = ''
          List of mountpoints giving data to the navidrome container.
          Will be mounted under /music/<name> in the container.
        '';
      };

      data = helpers.mkInheritedPathOption {
        parentName = "paths.default";
        parent = cfg.paths.default;
        defaultSubpath = "data";
        description = "Path for Navidrome appdata.";
      };
    };

    configuration = lib.mkOption {
      type = with types; attrsOf str;
      default = { };
      defaultText = "{}";
      description = "Passed as environment to Navidrome. See Navidrome docs";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;
    virtualisation.oci-containers.backend = "docker";

    virtualisation.oci-containers.containers = {
      navidrome = {
        image = "navidrome/navidrome:${cfg.version}";
        ports = helpers.webServicePort config cfg 8096;
        extraOptions = [ "--pull=always" ];
        environment = cfg.configuration;
        volumes = [ "${cfg.paths.data}:/data" ] ++ helpers.readOnly
          (helpers.multiplesVolumes cfg.paths.music "/music");
      };
    };
  };
}
