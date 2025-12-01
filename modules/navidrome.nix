{ config, helpers, lib, ... }:

with lib;
let cfg = config.control.navidrome;
in {
  options.control.navidrome = (helpers.webServiceDefaults {
    name = "Navidrome";
    version = "latest";
    subdomain = "navidrome";
    port = 10009;
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
        default = { mymusic = cfg.paths.default + "/music"; };
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

    systemd.tmpfiles.rules = [
      "d ${cfg.paths.default} 0755 1000 1000"
      "d ${cfg.paths.data} 0755 1000 1000"
    ] ++ map (x: "d ${x.value} 0755 1000 1000") (attrsToList cfg.paths.music);

    virtualisation.oci-containers.containers = {
      navidrome = {
        image = "deluan/navidrome:${cfg.version}";
        ports = helpers.webServicePort config cfg 4533;
        extraOptions = [ "--pull=always" ];
        environment = mkMerge [ cfg.configuration {
          PUID = "1000";
          PGID = "1000";
        } ];
        volumes = [ "${cfg.paths.data}:/data" ] ++ helpers.readOnly
          (helpers.multiplesVolumes cfg.paths.music "/music");
      };
    };
  };
}
