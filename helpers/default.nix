{ lib, ... }:

{
  mkNetworkService = { networkName, dockerCli }: {
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
  mkInheritedPathOption = { parentName, parent, defaultSubpath, description, }:
    lib.mkOption {
      type = lib.types.path;
      default = parent + "/${defaultSubpath}";
      defaultText = ''${parentName} + "/${defaultSubpath}"'';
      description =
        ''${parentName} (default to ${parentName} + "/${defaultSubpath}")'';
    };

  mkInheritedIntOption = { parentName, parent, description, }:
    lib.mkOption {
      type = lib.types.int;
      default = parent + 1;
      defaultText = "${parent + 1}";
      description = "(default to ${parentName} + 1)";
    };

  # Automates the creation of defaults for every standardized web service
  webServiceDefaults = { name, version, subdomain, port, }: {
    enable = lib.mkEnableOption "Enable ${name}";

    version = lib.mkOption {
      type = lib.types.str;
      default = version;
      defaultText = version;
      description = "Version name to use for ${name} images";
    };

    subdomain = lib.mkOption {
      type = lib.types.str;
      default = subdomain;
      defaultText = subdomain;
      description = "Subdomain to use for ${name}";
    };

    port = lib.mkOption {
      type = lib.types.int;
      default = port;
      defaultText = toString port;
      description = "Port to use for ${name}";
    };

    forceLan = lib.mkEnableOption ''
      Force LAN access, ignoring router configuration.
      You will be able to access this container on <lan_ip>:<port> regardless of your router configuration.
    '';

    lanOnly = lib.mkEnableOption ''
      Disable routing for this service. You will only be able to access it on your LAN.
    '';

    basicAuth = lib.mkOption {
      type = with lib.types; attrsOf str;
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
  webServicePort = globalConfig: moduleConfig: containerPort:
    [
      "${
        if (globalConfig.control.routing.lan || moduleConfig.forceLan
          || moduleConfig.lanOnly) then
          ""
        else
          "127.0.0.1:"
      }${toString moduleConfig.port}:${toString containerPort}"
    ];
  

  /* Takes an object like
     {
       name = "/path1";
       name2 = "/test/path2";
     }

     and a path to place them: "/my_path_in_container"

     Then gives an array of docker volumes :
     [
       "/path1:/my_path_in_container/name"
       "/test/path2:/my_path_in_container/name2"
     ]
  */
  multiplesVolumes = volumes: containerMountPath:
    lib.lists.forEach (lib.attrsets.attrsToList volumes)
    (e: "${e.value}:${containerMountPath}/${e.name}");

  # Append ":ro" to a list of volumes
  readOnly = volumes: lib.lists.forEach volumes (v: "${v}:ro");
}
