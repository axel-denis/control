{ config, helpers, lib, pkgs, ... }:

with lib;
let cfg = config.control.hdd-spindown;
in {
  options.control.hdd-spindown = {
    enable = mkEnableOption "Enable HDD spindown";

    timeoutSeconds = mkOption {
      type = types.int;
      default = 1200;
      defaultText = "1200";
      description = "Timeout in seconds before spinning down idle HDDs";
    };
  };

  config = mkIf cfg.enable {
    services.udev.extraRules = let
      mkRule = as: lib.concatStringsSep ", " as;
      mkRules = rs: lib.concatStringsSep "\n" rs;
    in mkRules ([
      (mkRule [
        ''ACTION=="add|change"''
        ''SUBSYSTEM=="block"''
        ''KERNEL=="sd[a-z]"''
        ''ATTR{queue/rotational}=="1"''
        ''
          RUN+="${pkgs.hdparm}/bin/hdparm -B 90 -S ${
            toString (cfg.timeoutSeconds / 5)
          } /dev/%k"''
      ])
    ]);
  };
}
