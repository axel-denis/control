{ config, helpers, lib, ... }:

with lib;
let cfg = config.control.pihole;
in {
  options.control.pihole = {
    enable = mkEnableOption "Enable Pi-hole";

    timezone = mkOption {
      type = types.str;
      default = config.time.timeZone;
      defaultText = "Your system timezone";
      description = ''
        Set the appropriate timezone for your location from
        https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
        Defaults to your system configuration (config.time.timeZone).
      '';
    };

    password = mkOption {
      type = types.str;
      description = "Base password for Pi-hole";
    };

    # NOTE - isn't exposed by the router

    version = mkOption {
      type = types.str;
      default = "latest";
      defaultText = "latest";
      description = "Version name to use for Pi-hole images";
    };

    port = mkOption {
      type = types.int;
      default = 10007;
      defaultText = "10007";
      description = "Http port to use for the Pi-hole web interface";
    };

    paths = {
      default = helpers.mkInheritedPathOption {
        parentName = "home server global default path";
        parent = config.control.defaultPath;
        defaultSubpath = "pihole";
        description = "Root path for Pi-hole appdata";
      };
    };
  };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;
    virtualisation.oci-containers.backend = "docker";

    virtualisation.oci-containers.containers = {
      pihole = {
        image = "pihole/pihole:${cfg.version}";
        ports = [ "${toString cfg.port}:80" "53:53/tcp" "53:53/udp" ];
        extraOptions = [ "--pull=always" ];
        environment = {
          TZ = cfg.timezone;
          FTLCONF_webserver_api_password = cfg.password;
          FTLCONF_dns_listeningMode = "all";
        };
        volumes = [ "${cfg.paths.default}:/etc/pihole" ];
      };
    };
  };
}
