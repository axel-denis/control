{ config, helpers, lib, pkgs, ... }:

with lib;
let cfg = config.control.terminal;
in {
  options.control.terminal = {
    enableOhMyZsh = mkEnableOption "Enable and activate Zsh";
    enableNeofetchGreet = mkEnableOption
      "Enable neofetch at the terminal startup (if zsh is enabled)";

    ohMyZshTheme = mkOption {
      type = types.str;
      default = "robbyrussell";
      defaultText = "robbyrussell";
      description = "Theme for oh-my-zsh";
    };

    enableCommandHelpers = mkEnableOption "Enable shortands for nix shell and nix run (ns and nr) for ZSH";
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
    (mkIf cfg.enableCommandHelpers {
      environment.etc."zshrc".text = ''
        ns() {
          if [ "$#" -eq 0 ]; then
            echo "Usage: ns <package1> [package2 ...]"
            return 1
          fi

          local args=()
          for pkg in "$@"; do
            args+=("nixpkgs#$pkg")
          done

          nix shell "''${args[@]}"
        }

        nr() {
          if [ "$#" -eq 0 ]; then
            echo "Usage: nr <package1> [args ...]"
            return 1
          fi

          local args=()
          for pkg in "$@"; do
            args+=("nixpkgs#$pkg")
          done

          nix shell "''${args[@]}"
        }
      '';
    })
    (mkIf ((cfg.enableCommandHelpers || cfg.enableNeofetchGreet) && (!cfg.enableOhMyZsh)) {
      warnings = ["Commands helpers are enabled but not OhMyZsh. Be aware that this function is made to run on ZSH"];
    })
  ];
}
