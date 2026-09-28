{
  config,
  helpers,
  lib,
  ...
}:

with lib;
let
  cfg = config.control;
in
{
  config = {
    systemd.services =
      mkIf
        (
          cfg.transmission.enable
          || cfg.jellyfin.enable
          || cfg.prowlarr.enable
          || cfg.seerr.enable
          || cfg.radarr.enable
        )
        (
          helpers.mkDockerNetworkService {
            networkName = "arr-net";
            dockerCli = "${config.virtualisation.docker.package}/bin/docker";
          }
        );
  };
}
