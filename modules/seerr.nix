{
  config,
  helpers,
  lib,
  ...
}:

with lib;
let
  cfg = config.control.seerr;
in
{
  options.control.seerr =
    (helpers.webServiceDefaults {
      name = "Seerr";
      version = "latest";
      subdomain = "seerr";
      port = 10014;
    })
    // {
      paths = {
        default = helpers.mkInheritedPathOption {
          parentName = "home server global default path";
          parent = config.control.defaultPath;
          defaultSubpath = "seerr";
          description = "Root path for Seerr appdata";
        };
      };
    };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;
    virtualisation.oci-containers.backend = "docker";

    # Creating directory with the user id asked by the container
    systemd.tmpfiles.rules = [ "d ${cfg.paths.default} 0755 1000 1000" ];
    virtualisation.oci-containers.containers = {
      seerr = {
        image = "ghcr.io/seerr-team/seerr:${cfg.version}";
        ports = helpers.webServicePort config cfg 5055;
        extraOptions = [
          (mkIf config.control.updateContainers "--pull=always")
          "--init"
          "--security-opt=no-new-privileges:true"
        ];
        capabilities = {
          ALL = false;
        };
        environment = {
          TZ = "Europe/Paris";
        };
        volumes = [ "${cfg.paths.default}:/app/config" ];
      };
    };
  };
}
