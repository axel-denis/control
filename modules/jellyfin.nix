{ config, helpers, lib, ... }:

with lib;
let cfg = config.control.jellyfin;
in {
  options.control.jellyfin = (helpers.webServiceDefaults {
    name = "Jellyfin";
    version = "latest";
    subdomain = "jellyfin";
    port = 10002;
  }) // {
    paths = {
      default = helpers.mkInheritedPathOption {
        parentName = "home server global default path";
        parent = config.control.defaultPath;
        defaultSubpath = "jellyfin";
        description = "Root path for Jellyfin media and appdata";
      };

      media = lib.mkOption {
        type = with types; attrsOf path;
        default = { mainmedia = parent + "/media"; };
        defaultText = ''{main_media = jellyfin_default_path + "/media";}'';
        description = ''
          List of mountpoints giving data to the jellyfin container.
          Will be mounted under /media/<name> in the container.
        '';
      };

      config = helpers.mkInheritedPathOption {
        parentName = "paths.default";
        parent = cfg.paths.default;
        defaultSubpath = "config";
        description = "Path for Jellyfin appdata (config).";
      };
    };
  };

  config = mkIf cfg.enable {
    

    virtualisation.oci-containers.containers = {
      jellyfin = {
        image = "jellyfin/jellyfin:${cfg.version}";
        ports = helpers.webServicePort config cfg 8096;
        extraOptions =
          [ (mkIf config.control.updateContainers "--pull=always") ];
        volumes = [ "${cfg.paths.config}:/config" ]
          ++ helpers.multiplesVolumes cfg.paths.media "/media";
      };
    };
  };
}
