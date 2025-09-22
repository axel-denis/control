{ config, helpers, lib, ... }:

with lib;
let
  cfg = config.homeserver.routing;
  webservices = [
   config.homeserver.immich
   config.homeserver.jellyfin
   config.homeserver.transmission
   config.homeserver.psitransfer
   config.homeserver.chibisafe
  ];
in
{
  options.homeserver.routing = {
    enable = mkEnableOption "Enable Nginx routing";

    domain = mkOption {
      type = types.string;
      default = "localhost";
      defaultText = "localhost";
      description = "Your domain name (example.com)";
    };

    letsencrypt = mkEnableOption "Enable Let's Encrypt (ACME) support";
    letsencryptEmail = mkOption {
      type = types.string;
      description = "Email address used for Let's Encrypt";
    };
  };

  config = mkIf cfg.enable {
    services.nginx = {
      enable = true;

      # TODO - filter out disabled services
      virtualHosts = listToAttrs (lib.lists.forEach webservices
        (value:
          lib.attrs.nameValuePair "${value.subdomain}.${cfg.domain}" {
            forceSSL = true;
            enableACME = true;
            locations."/" = {
              proxyPass = "http://127.0.0.1:${value.port}";
            };
          }
        ));
      # virtual hosts — TLS termination, ACME handled per vhost
      /*virtualHosts = {
        "photos.${cfg.domain}" = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:10001"; # Immich (container/local port)
          };
        };

        "films.${cfg.domain}" = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:10002"; # Jellyfin
          };
        };

        # speedtest as single-level subdomain (avoids Cloudflare 2-level wildcard problem)
        "speedtest.${cfg.domain}" = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:10004"; # Speedtest container (HTTP)
          };
        };

        # transmission — protected with HTTP Basic auth; hash is bcrypt (example)
        "transmission.${cfg.domain}" = {
          forceSSL = true;
          enableACME = true;
          basicAuth = {
            # map username -> bcrypt hashed password (example hash from earlier conversation)
            "transmission" = "$2y$05$1I2UVRbeafHLRl8RNUJZ6.e97IjGf/HkhCt898pnxVZ03PrxNgXOO";
          };
          locations."/" = {
            proxyPass = "http://127.0.0.1:10003"; # Transmission webui
          };
        };
      };*/
    };

  # Let's Encrypt (ACME)
  security.acme = mkIf cfg.letsencrypt {
    acceptTerms = true;
    defaults.email = cfg.letsencryptEmail;
    # NOTE - for testing, use staging CA to avoid rate limits:
    defaults.server = "https://acme-staging-v02.api.letsencrypt.org/directory";
  };

  networking.firewall = {
    # only allow http/https globally
    allowedTCPPorts = [ 80 443 ];

    # allow SSH only on the LAN interface enp2s0
    #interfaces."enp2s0".allowedTCPPorts = [ 22 ];
  };
}
