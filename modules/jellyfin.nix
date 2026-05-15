{
  config,
  helpers,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.control.jellyfin;
  name = "jellyfin";
in
{
  options.control.jellyfin =
    (helpers.webServiceDefaults {
      name = helpers.toName name;
      version = "latest";
      subdomain = name;
      port = 10002;
    })
    // {

      hardware-acceleration = {
        intel = mkEnableOption "Enables Intel hardware acceleration";
      };

      paths = {
        default = helpers.mkInheritedPathOption {
          parentName = "home server global default path";
          parent = config.control.defaultPath;
          defaultSubpath = name;
          description = "Root path for Jellyfin media and appdata";
        };

        media = lib.mkOption {
          type = with types; attrsOf path;
          default = {
            mainmedia = parent + "/media";
          };
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

  config = helpers.controlContainer cfg.enable name {

    virtualisation.oci-containers.containers = {
      ${name} = {
        podman.user = helpers.toUsername name;
        image = "jellyfin/jellyfin:${cfg.version}";
        ports = helpers.webServicePort config cfg 8096;
        extraOptions = [
          (mkIf config.control.updateContainers "--pull=always")
          (mkIf cfg.hardware-acceleration.intel "--group-add=${toString config.users.groups.render.gid}")
        ];
        volumes = [ "${cfg.paths.config}:/config" ] ++ helpers.multiplesVolumes cfg.paths.media "/media";
        devices = optionals cfg.hardware-acceleration.intel [ "/dev/dri/renderD128:/dev/dri/renderD128" ];
      };
    };
  };
}
