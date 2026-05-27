{
  lib,
  config,
  helpers,
  ...
}:

{
  options.control = {
    defaultPath = lib.mkOption {
      type = lib.types.str;
      default = "/control_appdata";
      defaultText = "/control_appdata";
      description = "Subdomain to use for all Control apps";
    };

    updateContainers = lib.mkEnableOption "Pulls the newest image of each enabled container";

    enableControl3Migration = lib.mkEnableOption "Allows Control3; Please read the release notes.";
    disableControl3MigrationWarning = lib.mkEnableOption "Disables the warning about the v3 migration";
  };

  config =
    let
      cfg = config.control;
    in
    {
      warnings =
        (lib.optionals (!cfg.disableControl3MigrationWarning && !cfg.enableControl3Migration) [
          ''
            CONTROL; 3.0

            Control; 3 introduces rootless podman for each container, read the release notes to know more.

            TLDR:
            Every webservice (immich, jellyfin...) now has its own user, and directories used in those apps must be chown-ed to the new user.
            You can do that manually, or enable control.enableControl3Migration

            You can disable this warning by enabling control.disableControl3MigrationWarning
          ''
        ])
        ++ (lib.optionals cfg.enableControl3Migration [
          ''
            control.enableControl3Migration -> one time option !
            It is advised to set it to false after the first use,
            otherwise it will run everytime at rebuild or startup.
          ''
        ]) ++ (map (m: m.name + " -> " + lib.concatStrings (lib.strings.intersperse "\n" m.value._meta.paths)) (helpers.controlModulesList cfg));

      systemd.services."podman-jellyfin".serviceConfig.Type = lib.mkForce "simple";
      virtualisation.podman.enable = true;
      virtualisation.oci-containers.backend = "podman";
      virtualisation.podman.dockerCompat = true;
      virtualisation.podman.defaultNetwork.settings.dns_enabled = true;
    };
}

# TODO : verifier les paths qui seraient overlap entre deux containers (pose probleme avec le chmod)
