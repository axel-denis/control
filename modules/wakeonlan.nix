{ config, helpers, lib, pkgs, ... }:

with lib;
let cfg = config.homeserver.wakeonlan;
in {
  options.homeserver.wakeonlan = {
    enable = mkEnableOption "Enable wake on lan";

    interface = mkOption {
      type = types.str;
      description = "Network interface name";
      example = "enp3s0";
    };
  };

  config = mkIf cfg.enable {
    networking.interfaces.${cfg.interface}.wakeOnLan.enable = true;
  };
}
