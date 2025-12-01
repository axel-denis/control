{ config, helpers, lib, ... }:

with lib;
let cfg = config.control.slskd;
in {
  options.control.slskd = (helpers.webServiceDefaults {
    name = "slskd";
    version = "latest";
    subdomain = "slskd";
    port = 10010;
  }) // {
    paths = {
      default = helpers.mkInheritedPathOption {
        parentName = "home server global default path";
        parent = config.control.defaultPath;
        defaultSubpath = "slskd";
        description = "Root path for slskd media and appdata";
      };

      directories = lib.mkOption {
        type = with types; attrsOf path;
        default = { mymusic = cfg.paths.default + "/music"; };
        defaultText = ''{mymusic = paths.default + "/music";}'';
        description = ''
          List of mountpoints giving data to the slskd container.
          Will be mounted under /<name> in the container.
        '';
      };

      data = helpers.mkInheritedPathOption {
        parentName = "paths.default";
        parent = cfg.paths.default;
        defaultSubpath = "data";
        description = "Path for slskd appdata.";
      };
    };

    configuration = lib.mkOption {
      type = with types; attrsOf str;
      default = { };
      defaultText = "{ }";
      description = "Passed as environment to slskd. See slskd docs";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;
    virtualisation.oci-containers.backend = "docker";

    assertions = [{
      assertion = (cfg.configuration ? SLSKD_SLSK_USERNAME)
        && (cfg.configuration ? SLSKD_SLSK_PASSWORD);
      message =
        "Please provide control.slskd.SLSKD_SLSK_USERNAME and control.slskd.SLSKD_SLSK_PASSWORD for slskd to start.";
    }];

    systemd.tmpfiles.rules = [
      "d ${cfg.paths.default} 0755 1000 1000"
      "d ${cfg.paths.data} 0755 1000 1000"
    ] ++ map (x: "d ${x.value} 0755 1000 1000") (attrsToList cfg.paths.directories);

    virtualisation.oci-containers.containers = {
      slskd = {
        image = "slskd/slskd:${cfg.version}";
        ports = (helpers.webServicePort config cfg 5031) ++ [ "50300:50300" ];
        extraOptions = [ "--pull=always" ];
        environment = mkMerge [
          cfg.configuration 
          {
            PUID = "1000";
            PGID = "1000";
            SLSKD_SHARED_DIR = concatStrings (lists.forEach (attrsets.attrsToList cfg.paths.directories) (e: "/${e.name};"));
          }
        ];
        user = "1000:1000";
        volumes = [ "${cfg.paths.data}:/app" ] ++ helpers.readOnly
          (helpers.multiplesVolumes cfg.paths.directories "");
      };
    };
  };
}
