{ lib, ... }:

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

  mkInheritedIntOption = { parentName, parent, description }:
    lib.mkOption {
      type = lib.types.int;
      default = parent + 1;
      defaultText = "${parent + 1}";
      description = "(default to ${parentName} + 1)";
    };

  # Automates the creation of defaults for every standardized web service
  webServiceDefaults = { name, version, subdomain, port }: {
    enable = mkEnableOption "Enable ${name}";

    version = mkOption {
      type = types.str;
      default = version;
      defaultText = version;
      description = "Version name to use for ${name} images";
    };

    subdomain = mkOption {
      type = types.str;
      default = subdomain;
      defaultText = subdomain;
      description = "Subdomain to use for ${name}";
    };

    port = mkOption {
      type = types.int;
      default = port;
      defaultText = toString port;
      description = "Port to use for ${name}";
    };

    forceLan = mkEnableOption ''
      Force LAN access, ignoring router configuration.
      You will be able to access this container on <lan_ip>:<port> regardless of your router configuration.
    '';

    lanOnly = mkEnableOption ''
      Disable routing for this service. You will only be able to access it on your LAN.
    '';

    basicAuth = mkOption {
      type = with types; attrsOf str;
      default = { };
      description = ''
        If set, enable Nginx basic authentication for this service.
        The value should be an attribute set of username-password pairs, e.g.
        { user1 = "password1"; user2 = "password2"; }
        Keep in mind that basic authentication works for web pages but can break dependant services (e.g. mobile apps).
        It is also known to break ACME.
      '';
    };
  };

  # Setting containers exposure for webservices
  webServicePort = globalConfig: moduleConfig: [
    "${
      if (globalConfig.control.routing.lan || moduleConfig.forceLan || moduleConfig.lanOnly) then
        ""
      else
        "127.0.0.1:"
    }${toString moduleConfig.port}:3000"
  ];
}
