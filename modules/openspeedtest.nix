{
  config,
  helpers,
  lib,
  ...
}:

with lib;
let
  cfg = config.control.openspeedtest;
  name = "openspeedtest";
in
{
  options.control.openspeedtest = helpers.webServiceDefaults {
    name = "OpenSpeedTest";
    version = "latest";
    subdomain = name;
    port = 10006;
  };

  config = helpers.controlContainer cfg.enable name [ ] config.control.enableControl3Migration {

    virtualisation.oci-containers.containers = {
      ${name} = {
        podman.user = helpers.toUsername name;
        image = "openspeedtest/${cfg.version}";
        ports = helpers.webServicePort config cfg 3000;
        extraOptions = [
          (mkIf config.control.updateContainers "--pull=always")
          "--userns=keep-id"
          "--group-add=keep-groups"
        ];
      };
    };
  };
}
