{ config, helpers, lib, ... }:

with lib;
let
  cfg = config.homeserver.routing;

  # collect all (enabled) web-services
  webservices = filter (module:
    module ? enable && module.enable && module ? subdomain && module ? port
  ) (attrsets.mapAttrsToList (name: value: value) config.homeserver);

in
{
  options.homeserver.routing = {
    enable = mkEnableOption "Enable Nginx routing";

    lan = mkOption {
      type = types.bool;
      default = !cfg.enable;
      defaultText = "Disabled if routing is enabled, else enabled";
      description = "Enable LAN access of services (bypassing Nginx)";
    };

    domain = mkOption {
      type = types.string;
      default = "localhost";
      defaultText = "localhost";
      description = "Your domain name (example.com)";
    };

    letsencrypt = {
      enable = mkEnableOption "Enable Let's Encrypt (ACME) support";
      email = mkOption {
        type = types.string;
        description = "Email address used for Let's Encrypt";
      };
      test-mode = mkEnableOption "Enable test server for Let's Encrypt";
    };
  };

  config = mkIf cfg.enable {
    services.nginx = {
      enable = true;

      # TODO - can listen on lan by listening to 0.0.0.0
      virtualHosts = listToAttrs (lists.forEach webservices
        (module:
          attrsets.nameValuePair "${module.subdomain}.${cfg.domain}" {
            forceSSL = cfg.letsencrypt.enable;
            enableACME = cfg.letsencrypt.enable;
            locations."/" = {
              proxyPass = "http://127.0.0.1:${toString module.port}";
            };
            # TODO - tune values
            extraConfig = ''
              client_max_body_size 35M;
            '';
          }
        ));
    };

    # Let's Encrypt (ACME)
    security.acme = mkIf cfg.letsencrypt.enable {
      acceptTerms = true;
      defaults.email = cfg.letsencrypt.email;
      # NOTE - for testing: uses staging CA to avoid rate limits:
      defaults.server = mkIf cfg.letsencrypt.test-mode "https://acme-staging-v02.api.letsencrypt.org/directory";
    };

    # FIXME - why still accessible with containers ports ?
    networking.firewall = {
      allowedTCPPorts = [ 80 443 ];
    };
  };
}
