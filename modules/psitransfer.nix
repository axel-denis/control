{ config, helpers, lib, ... }:

with lib;
let cfg = config.homeserver.psitransfer;
in {
  options.homeserver.psitransfer = {
    enable = mkEnableOption "Enable Psitransfer";

    version = mkOption {
      type = types.string;
      default = "latest";
      defaultText = "latest";
      description = "Version name to use for Psitransfer images";
    };

    port = mkOption {
      type = types.int;
      default = 10005;
      defaultText = "10005";
      description = "Port to use for Psitransfer";
    };

    paths = {
      default = mkOption {
        type = types.path;
        description = "Root path for Psitransfer media and appdata (required)";
      };
    };

    admin-password = mkOption {
      type = types.string;
      default = "secret"; # REVIEW - maybe remove default to force user to specify
      defaultText = "secret";
      description = "Base password for Psitransfer admin user (change this!)";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.containers.enable = true;
    virtualisation.oci-containers.backend = "podman";
    virtualisation = {
      podman = {
        enable = true;

        # Create a `docker` alias for podman, to use it as a drop-in replacement
        dockerCompat = true;

        # Required for containers under podman-compose to be able to talk to each other.
        defaultNetwork.settings.dns_enabled = true;
      };
    };

    virtualisation.oci-containers.containers = {
      psitransfer = {
        image = "psitrax/psitransfer:${cfg.version}";
        ports = [ "${toString cfg.port}:3000" ];
        environment = {
          PSITRANSFER_ADMIN_PASS = cfg.admin-password;
        };
        volumes = [
          "${cfg.paths.default}:/data"
        ];
      };
    };
  };
}

