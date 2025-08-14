{ lib }:

{
  mkDockerNetworkService = { networkName, dockerCli }: {
    "init-${networkName}-network" = {
      description = "Create Docker network bridge: ${networkName}";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "oneshot";
      script = ''
        check=$(${dockerCli} network ls | grep -w "${networkName}" || true)
        if [ -z "$check" ]; then
          ${dockerCli} network create ${networkName}
        else
          echo "${networkName} already exists in Docker"
        fi
      '';
    };
  };
}
