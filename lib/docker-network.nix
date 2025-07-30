{ lib }:

{
  mkDockerNetworkService = networkName: config:
    let dockercli = "${config.virtualisation.docker.package}/bin/docker";
    in {
      "init-${networkName}-network" = {
        description = "Create Docker network bridge: ${networkName}";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig.Type = "oneshot";
        script = ''
          check=$(${dockercli} network ls | grep -w "${networkName}" || true)
          if [ -z "$check" ]; then
            ${dockercli} network create ${networkName}
          else
            echo "${networkName} already exists in Docker"
          fi
        '';
      };
    };
}
