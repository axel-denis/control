{ config, helpers, lib, ... }:

with lib;
let cfg = config.control.openspeedtest;
in {
  options.control.openspeedtest = helpers.webServiceDefaults {
    name = "OpenSpeedTest";
    version = "latest";
    subdomain = "openspeedtest";
    port = 10006;
  };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;
    virtualisation.oci-containers.backend = "docker";

    virtualisation.oci-containers.containers = {
      openspeedtest = {
        image = "openspeedtest/${cfg.version}";
        ports = helpers.webServicePort config cfg 3000;
        extraOptions = [ (mkIf config.control.updateContainers "--pull-always") ];
      };
    };
  };
}
