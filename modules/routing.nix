{ config, helpers, lib, pkgs, ... }:

with lib;
let
  cfg = config.control.routing;

  # collect all (enabled) web-services
  webservices = filter (module:
    module ? enable && module.enable && module ? subdomain && module ? port
    && module ? lanOnly && !module.lanOnly)
    (attrsets.mapAttrsToList (name: value: value) config.control);

  # Cloudflare's Authenticated Origin Pulls CA certificate
  cloudflareCertificate = pkgs.fetchurl {
    url =
      "https://developers.cloudflare.com/ssl/static/authenticated_origin_pull_ca.pem";
    sha256 = "sha256-wU/tDOUhDbBxn+oR0fELM3UNwX1gmur0fHXp7/DXuEM=";
  };
in {
  options.control.routing = {
    enable = mkEnableOption "Enable Nginx routing";

    lan = mkOption {
      type = types.bool;
      default = !cfg.enable;
      defaultText = "Disabled if routing is enabled, else enabled";
      description = "Enable LAN access of services (bypassing Nginx)";
    };

    domain = mkOption {
      type = types.str;
      default = "localhost";
      defaultText = "localhost";
      description = "Your domain name (example.com)";
    };

    letsencrypt = {
      enable = mkEnableOption "Enable Let's Encrypt (ACME) support";
      email = mkOption {
        type = types.str;
        description = "Email address used for Let's Encrypt";
      };
      test-mode = mkEnableOption "Enable test server for Let's Encrypt";
    };

    checkClientCertificate = mkEnableOption ''
      Checks that the incoming requests present a specific client certificate.
      This is mainly useful to ensure that requests come to a trusted proxy (e.g. Cloudflare).
      The default certificate is Cloudflare's Authenticated Origin Pulls CA. You can replace it by setting
      the `clientCertificateFile` option.
    '';

    clientCertificateFile = mkOption {
      type = types.path;
      default = cloudflareCertificate;
      defaultText = "Cloudflare's Authenticated Origin Pulls CA";
      description = ''
        Path to a PEM file containing the client certificate to check for. If `checkClientCertificate` is enabled.
        Will only accept requests presenting this certificate. (At Nginx level)
        Defaults to Cloudflare's Authenticated Origin Pulls CA certificate.
      '';
    };
  };

  config = mkIf cfg.enable {
    services.nginx = {
      enable = true;

      appendHttpConfig = strings.concatStringsSep "\n" [
        ''
          add_header X-Frame-Options "SAMEORIGIN";
          add_header X-Content-Type-Options "nosniff";
          add_header Referrer-Policy "strict-origin-when-cross-origin";
          add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
        ''
        ''
          geo $is_local {
            default 0;
            127.0.0.1/32 1;
            ::1/128 1;
            192.168.0.0/16 1;
          }

          # Set a variable that marks requests to reject
          map "$is_local:$ssl_client_verify" $reject_client {
            # local clients -> always OK
            "~^1:"           0;
            # external with verified cert -> OK
            "~^0:SUCCESS"    0;
            # everything else -> reject
            default           1;
          }
        ''
        (if cfg.checkClientCertificate then
          "ssl_client_certificate ${cfg.clientCertificateFile};"
        else
          "")
        (if cfg.checkClientCertificate then
          "ssl_verify_client optional;"
        else
          "")
      ];

      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts = listToAttrs (lists.forEach webservices (module:
        attrsets.nameValuePair "${module.subdomain}.${cfg.domain}" {
          forceSSL = cfg.letsencrypt.enable;
          enableACME = cfg.letsencrypt.enable;
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString module.port}";
            proxyWebsockets =
              true; # TODO -> only for really required apps (immich)
            basicAuth = module.basicAuth;
          };
          extraConfig = strings.concatStringsSep "\n" [
            # TODO -> large body size only for really required apps (immich)
            "client_max_body_size 5000M;"
            (if cfg.checkClientCertificate then ''
              if ($reject_client) {
                return 403;
              }
            '' else
              "")
          ];
        }));
    };

    # Let's Encrypt (ACME)
    security.acme = mkIf cfg.letsencrypt.enable {
      acceptTerms = true;
      defaults.email = cfg.letsencrypt.email;
      # NOTE - for testing: uses staging CA to avoid rate limits:
      defaults.server = mkIf cfg.letsencrypt.test-mode
        "https://acme-staging-v02.api.letsencrypt.org/directory";
    };

    networking.firewall = { allowedTCPPorts = [ 80 443 ]; };
  };
}
