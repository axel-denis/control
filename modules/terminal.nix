{ config, helpers, lib, ... }:

with lib;
let cfg = config.homeserver.terminal;
in {
  options.homeserver.terminal = {
    enableOhMyZsh = mkEnableOption "Enable and activate Zsh";

    ohMyZshTheme = mkOption {
      type = types.string;
      default = "robbyrussell";
      defaultText = "robbyrussell";
      description = "Theme for oh-my-zsh";
    };

    enableNeofetchGreet = mkEnableOption "Enable neofetch at the terminal startup (if zsh is enabled)";
  };

  config = mkMerge [
    (mkIf cfg.enableOhMyZsh {
      programs.zsh.enable = true;
      users.defaultUserShell = pkgs.zsh;
      programs.zsh.ohMyZsh = {
        enable = true;
        theme = cfg.ohMyZshTheme;
      };
    })
    (mkIf cfg.enableNeofetchGreet {
      environment.etc."zprofile".text = ''
        neofetch
      '';
    })
  ];
}