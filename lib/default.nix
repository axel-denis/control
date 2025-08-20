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

  /* Automates the creation of an inherited option like :
     dbPath = mkOption {
       type = types.path;
       default = cfg.mainPath + "/db";
       defaultText = ''mainPath + "/db"'';
       description = "Path for database (default to `mainPath`/db)";
     };
  */
  mkInheritedPathOption = { parentName, parent, defaultSubpath, description }:
    lib.mkOption {
      type = lib.types.path;
      default = parent + "/${defaultSubpath}";
      defaultText = ''${parentName} + "/${defaultSubpath}"'';
      description =
        ''${parentName} (default to ${parentName} + "/${defaultSubpath}")'';
    };
}
