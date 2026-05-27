{ lib }:

let
  strings = import ./strings.nix { inherit lib; };
in
with lib;
{
  # Setting containers exposure for webservices
  webServicePort = globalConfig: moduleConfig: containerPort: [
    "${
      if (globalConfig.control.routing.lan || moduleConfig.forceLan || moduleConfig.lanOnly) then
        ""
      else
        "127.0.0.1:"
    }${toString moduleConfig.port}:${toString containerPort}"
  ];

  multiplesVolumes =
    volumes: containerMountPath:
    lists.forEach (attrsets.attrsToList volumes) (e: "${e.value}:${containerMountPath}/${e.name}");

  multiplesVolumesToPaths = volumes: lib.mapAttrsToList (name: value: toString value) volumes;

  # Automates the creation of defaults for every standardized web service
  webServiceDefaults =
    {
      name,
      version,
      subdomain,
      port,
    }:
    {
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

  controlContainer =
    with strings;
    enabled: name: paths: remapPaths: conf:
    (mkIf (enabled) (
      let
        username = toUsername name;
        groupname = toGroupname name;
      in
      {
        users.users.${username} = {
          isNormalUser = true;
          group = groupname;
          linger = true;
          createHome = true;
          home = "/var/lib/${username}";
          autoSubUidGidRange = true;
        };
        users.groups.${groupname} = { };

        systemd.tmpfiles.rules = (
          mkIf remapPaths lists.flatten (
            map (p: [
              "d ${p} 0700 ${username} ${groupname} - -"
              "Z ${p} 0700 ${username} ${groupname} - -"
            ]) paths

          )
        );
      }
      // conf
    ));
}
