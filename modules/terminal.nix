{
  config,
  helpers,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.control.terminal;
in
{
  options.control.terminal = {
    enableOhMyZsh = mkEnableOption "Enable and activate Zsh";
    enableNeofetchGreet = mkEnableOption "Enable neofetch at the terminal startup (if zsh is enabled)";

    ohMyZshTheme = mkOption {
      type = types.str;
      default = "robbyrussell";
      defaultText = "robbyrussell";
      description = "Theme for oh-my-zsh";
    };
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
        ${pkgs.neofetch}/bin/neofetch
      '';
    })
  ];
}
